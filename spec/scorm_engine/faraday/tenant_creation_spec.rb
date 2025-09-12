# frozen_string_literal: true

require "spec_helper"
require_relative "../../../support/scorm_engine_configuration"

RSpec.describe ScormEngine::Faraday::TenantCreation do
  subject(:client) { described_class.new(tenant: tenant_name, tenant_creator: tenant_creator, connection: mock_connection) }

  describe "tenant creation behavior" do
    context "when tenant_creator is provided" do
      let(:tenant_name) { "test-tenant" }
      let(:tenant_creator) { instance_spy("TenantCreator") }
      let(:mock_connection) { instance_spy(Faraday::Connection) }

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
      let(:tenant_name) { "test-tenant" }
      let(:mock_connection) { instance_spy(Faraday::Connection) }
      let(:mock_request) { instance_spy(Faraday::Request) }
      let(:client_without_creator) { described_class.new(tenant: tenant_name, connection: mock_connection) }

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
    let(:tenant_name) { "test-tenant" }
    let(:mock_connection) { instance_spy(Faraday::Connection) }

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
