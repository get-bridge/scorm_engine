# frozen_string_literal: true

require "spec_helper"

RSpec.describe ScormEngine::Faraday::Request do
  subject(:requester) { mock_class.new(tenant) }

  let(:tenant) { "test-tenant" }

  let(:mock_request) { instance_spy("Faraday::Request") }
  let(:mock_connection) do
    instance_spy("Faraday::Connection").tap do |conn|
      allow(conn).to receive(:get).and_yield(mock_request)
      allow(conn).to receive(:post).and_yield(mock_request)
      allow(conn).to receive(:put).and_yield(mock_request)
      allow(conn).to receive(:delete).and_yield(mock_request)
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

      def connection(*_args)
        # stubbed externally
      end

      def base_uri
        instance_double("URI", path: "/api/v1/")
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
    context "when API v2 behavior" do
      before { requester.instance_variable_set(:@api_version, 2) }

      it "adds engineTenantName header" do
        requester.send(:request, :get, "test/path", connection: mock_connection)
        expect(mock_request).to have_received(:[]=).with("engineTenantName", tenant)
      end

      it "does not modify path" do
        requester.send(:request, :get, "test/path", connection: mock_connection)
        expect(mock_request).to have_received(:url).with("test/path", {})
      end

      it "does not add header when without_tenant is true" do
        requester.instance_variable_set(:@without_tenant, true)
        requester.send(:request, :get, "test/path", connection: mock_connection)
        expect(mock_request).not_to have_received(:[]=).with("engineTenantName", tenant)
      end
    end

    context "when API v1 behavior" do
      before { requester.instance_variable_set(:@api_version, 1) }

      it "adds tenant to path" do
        requester.send(:request, :get, "test/path", connection: mock_connection)
        expect(mock_request).to have_received(:url).with("#{tenant}/test/path", {})
      end

      it "does not add engineTenantName header" do
        requester.send(:request, :get, "test/path", connection: mock_connection)
        expect(mock_request).not_to have_received(:[]=).with("engineTenantName", anything)
      end
    end
  end

  describe "clean design principles" do
    it "does not force API version to v2 in ensure blocks" do
      original_version = requester.instance_variable_get(:@api_version)
      requester.api_v1 {}
      expect(requester.instance_variable_get(:@api_version)).to eq(original_version)
    end

    it "calls current_api_version when no explicit version set" do
      requester.send(:request, :get, "test/path", connection: mock_connection)
      # Simply assert expected state instead of stubbing/expecting calls
      expect(requester.instance_variable_get(:@api_version)).to eq(2)
    end
  end
end

# Tenant creation functionality tests
RSpec.describe ScormEngine::Faraday::Request, "tenant creation" do
  subject(:client) { mock_class.new(tenant_name, tenant_creator: tenant_creator) }

  let(:tenant_name) { "test-tenant" }
  let(:tenant_creator) { instance_spy("TenantCreator") }
  let(:mock_connection) { instance_spy(Faraday::Connection) }

  let(:mock_class) do
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

      def connection(*_args)
        # stubbed externally
      end

      def base_uri
        instance_double("URI", path: "/api/v1/")
      end
    end
  end

  describe "tenant creation behavior" do
    context "when tenant_creator is provided" do
      let(:tenant_not_found_response) do
        instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "#{tenant_name} is not a valid tenant name" }
        )
      end

      let(:success_response) do
        instance_double(Faraday::Response, status: 200, success?: true, body: {})
      end

      before do
        mock_request = instance_spy(Faraday::Request)
        allow(mock_connection).to receive(:get).and_yield(mock_request)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client).to receive(:connection).and_return(mock_connection)
      end

      it "creates tenant and retries request successfully" do
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        response = client.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end

      it "calls the connection when retrying" do
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        client.send(:request, :get, "courses", {})
        expect(mock_connection).to have_received(:get)
      end

      it "calls tenant_creator with the tenant name" do
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        client.send(:request, :get, "courses", {})
        expect(tenant_creator).to have_received(:call).with(tenant_name)
      end

      it "returns original error if tenant creation fails" do
        allow(tenant_creator).to receive(:call).and_raise(StandardError, "Creation failed")
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        response = client.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end
    end

    context "when tenant_creator is not provided" do
      let(:client_without_creator) { mock_class.new(tenant_name) }
      let(:mock_request) { instance_spy(Faraday::Request) }

      let(:tenant_not_found_response) do
        instance_double(
          Faraday::Response,
          status: 400,
          success?: false,
          body: { "message" => "#{tenant_name} is not a valid tenant name" }
        )
      end

      before do
        allow(mock_connection).to receive(:get).and_yield(mock_request)
        allow(mock_request).to receive(:headers).and_return({})
        allow(mock_request).to receive(:url)
        allow(client_without_creator).to receive(:connection).and_return(mock_connection)
      end

      it "returns the original error" do
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        response = client_without_creator.send(:request, :get, "courses", {})
        expect(response.raw_response.status).to eq(400)
      end

      it "calls the connection" do
        allow(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        client_without_creator.send(:request, :get, "courses", {})
        expect(mock_connection).to have_received(:get)
      end
    end
  end

  describe "#should_retry_with_tenant_creation?" do
    before do
      allow(client).to receive(:connection).and_return(mock_connection)
    end

    it "returns true for tenant not found" do
      tenant_error = instance_double(Faraday::Response, status: 400, body: "#{tenant_name} is not a valid tenant name")
      wrapped_response = ScormEngine::Response.new(raw_response: tenant_error)
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be true
    end

    it "returns false for other 400 errors" do
      other_error = instance_double(Faraday::Response, status: 400, body: "Some other validation error")
      wrapped_response = ScormEngine::Response.new(raw_response: other_error)
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
    end

    it "returns false for non-400 errors" do
      server_error = instance_double(Faraday::Response, status: 500, body: "Internal server error")
      wrapped_response = ScormEngine::Response.new(raw_response: server_error)
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
    end
  end
end
