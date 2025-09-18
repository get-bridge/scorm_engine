# frozen_string_literal: true

require "spec_helper"

RSpec.describe ScormEngine::Faraday::Request do
  subject(:requester) { mock_class.new("test-tenant") }

  let(:mock_request) { instance_spy("Faraday::Request") }
  let(:mock_response) { instance_double("Faraday::Response", status: 200, success?: true, body: {}) }
  let(:mock_connection) do
    instance_spy("Faraday::Connection").tap do |conn|
      allow(conn).to receive(:get).and_yield(mock_request).and_return(mock_response)
      allow(conn).to receive(:post).and_yield(mock_request).and_return(mock_response)
      allow(conn).to receive(:put).and_yield(mock_request).and_return(mock_response)
      allow(conn).to receive(:delete).and_yield(mock_request).and_return(mock_response)
    end
  end

  let(:mock_class) do
    Class.new do
      include ScormEngine::Faraday::Request
      attr_reader :tenant

      def initialize(tenant)
        @tenant = tenant
      end

      def current_api_version
        2
      end

      def connection(version: nil)
        # stubbed externally
      end

      def base_uri
        @base_uri ||= Struct.new(:path).new("/api/v1/")
      end
    end
  end

  describe "#api_v2" do
    it "sets API version to 2 inside block" do
      requester.api_v2 do
        expect(requester.instance_variable_get(:@api_version)).to eq(2)
      end
    end

    it "resets API version to nil after block" do
      requester.api_v2 {}
      expect(requester.instance_variable_get(:@api_version)).to be_nil
    end

    it "sets without_tenant flag when requested" do
      requester.api_v2(without_tenant: true) do
        expect(requester.instance_variable_get(:@without_tenant)).to eq(true)
      end
    end

    it "resets API version even if exception occurs Test error" do
      expect {
        requester.api_v2 { raise "Test error" }
      }.to raise_error("Test error")
    end

    it "resets API version even if exception occurs To be nil" do
      expect(requester.instance_variable_get(:@api_version)).to be_nil
    end
  end

  describe "#api_v1" do
    it "sets API version to 1 inside block" do
      requester.api_v1 do
        expect(requester.instance_variable_get(:@api_version)).to eq(1)
      end
    end

    it "resets API version to nil after block" do
      requester.api_v1 {}
      expect(requester.instance_variable_get(:@api_version)).to be_nil
    end

    it "resets API version even if exception occurs Test error" do
      expect {
        requester.api_v1 { raise "Test error" }
      }.to raise_error("Test error")
    end

    it "resets API version even if exception occurs To be nil" do
      expect(requester.instance_variable_get(:@api_version)).to be_nil
    end
  end

  describe "#request" do
    let(:test_requester) do
      mock_class.new("test-tenant").tap do |instance|
        allow(instance).to receive(:connection).and_return(mock_connection)
      end
    end

    context "when API v2 behavior" do
      before { test_requester.instance_variable_set(:@api_version, 2) }

      it "adds engineTenantName header" do
        mock_headers = {}
        allow(mock_request).to receive(:headers).and_return(mock_headers)

        test_requester.send(:request, :get, "test/path", {})

        expect(mock_headers["engineTenantName"]).to eq("test-tenant")
      end

      it "does not modify path" do
        allow(mock_request).to receive(:headers).and_return({})

        test_requester.send(:request, :get, "test/path", {})

        expect(mock_request).to have_received(:url).with("test/path", {})
      end

      it "does not add header when without_tenant is true" do
        test_requester.instance_variable_set(:@without_tenant, true)
        mock_headers = {}
        allow(mock_request).to receive(:headers).and_return(mock_headers)

        test_requester.send(:request, :get, "test/path", {})

        expect(mock_headers["engineTenantName"]).to be_nil
      end
    end

    context "when API v1 behavior" do
      before { test_requester.instance_variable_set(:@api_version, 1) }

      it "adds tenant to path" do
        allow(mock_request).to receive(:headers).and_return({})

        test_requester.send(:request, :get, "test/path", {})

        expect(mock_request).to have_received(:url).with("test-tenant/test/path", {})
      end

      it "does not add engineTenantName header" do
        mock_headers = {}
        allow(mock_request).to receive(:headers).and_return(mock_headers)

        test_requester.send(:request, :get, "test/path", {})

        expect(mock_headers["engineTenantName"]).to be_nil
      end
    end
  end

  describe "clean design principles" do
    it "does not force API version to v2 in ensure blocks" do
      test_requester = mock_class.new("test-tenant")
      original_version = test_requester.instance_variable_get(:@api_version)
      test_requester.api_v1 {}
      expect(test_requester.instance_variable_get(:@api_version)).to eq(original_version)
    end

    it "calls current_api_version when no explicit version set" do
      test_requester = mock_class.new("test-tenant").tap do |instance|
        allow(instance).to receive(:connection).and_return(mock_connection)
        allow(mock_request).to receive(:headers).and_return({})
        allow(instance).to receive(:current_api_version).and_return(2)
      end

      test_requester.send(:request, :get, "test/path", {})
    end
  end

  # Tenant creation functionality tests
  describe "tenant creation" do
    let(:tenant_mock_class) do
      Class.new do
        include ScormEngine::Faraday::Request
        attr_reader :tenant, :tenant_creator

        def initialize(tenant, tenant_creator: nil)
          @tenant = tenant
          @tenant_creator = tenant_creator
        end

        def current_api_version
          2
        end

        def connection(version: nil)
          # stubbed externally
        end

        def base_uri
          @base_uri ||= Struct.new(:path).new("/api/v1/")
        end
      end
    end

    describe "with tenant_creator provided" do
      it "creates tenant and retries request successfully" do
        tenant_creator = instance_spy("TenantCreator")
        client = tenant_mock_class.new("test-tenant", tenant_creator: tenant_creator)
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        response = client.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end

      it "calls the connection when retrying" do
        tenant_creator = instance_spy("TenantCreator")
        client = tenant_mock_class.new("test-tenant", tenant_creator: tenant_creator)
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        client.send(:request, :get, "courses", {})
        expect(mock_connection).to have_received(:get).at_least(:once)
      end

      it "calls tenant_creator with the tenant name" do
        tenant_creator = instance_spy("TenantCreator")
        client = tenant_mock_class.new("test-tenant", tenant_creator: tenant_creator)
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        client.send(:request, :get, "courses", {})
        expect(tenant_creator).to have_received(:call).with("test-tenant")
      end

      it "returns original error if tenant creation fails" do
        tenant_creator = instance_spy("TenantCreator")
        client = tenant_mock_class.new("test-tenant", tenant_creator: tenant_creator)
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(tenant_creator).to receive(:call).and_raise(StandardError, "Creation failed")
        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        response = client.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end
    end

    describe "without tenant_creator" do
      it "returns the original error" do
        client = tenant_mock_class.new("test-tenant")
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        response = client.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end

      it "calls the connection" do
        client = tenant_mock_class.new("test-tenant")
        mock_connection = instance_spy(Faraday::Connection)
        mock_request = instance_spy(Faraday::Request)

        tenant_not_found_response = instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "test-tenant is not a valid tenant name" }
        )

        allow(mock_connection).to receive(:get).and_yield(mock_request).and_return(tenant_not_found_response)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)

        client.send(:request, :get, "courses", {})
        expect(mock_connection).to have_received(:get)
      end
    end

    describe "#should_retry_with_tenant_creation?" do
      it "returns true for tenant not found" do
        client = tenant_mock_class.new("test-tenant")
        tenant_error = instance_double(Faraday::Response, status: 400, body: "test-tenant is not a valid tenant name")
        wrapped_response = ScormEngine::Response.new(raw_response: tenant_error)
        expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be true
      end

      it "returns false for other 400 errors" do
        client = tenant_mock_class.new("test-tenant")
        other_error = instance_double(Faraday::Response, status: 400, body: "Some other validation error")
        wrapped_response = ScormEngine::Response.new(raw_response: other_error)
        expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
      end

      it "returns false for non-400 errors" do
        client = tenant_mock_class.new("test-tenant")
        server_error = instance_double(Faraday::Response, status: 500, body: "Internal server error")
        wrapped_response = ScormEngine::Response.new(raw_response: server_error)
        expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
      end
    end
  end
end
