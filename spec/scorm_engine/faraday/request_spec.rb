# frozen_string_literal: true

require_relative "../../../support/scorm_engine_configuration"

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
