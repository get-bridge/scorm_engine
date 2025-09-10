require "spec_helper"
require_relative "../../../support/scorm_engine_configuration"

RSpec.describe "ScormEngine Tenant Auto-Creation" do
  let(:tenant_name) { "test-tenant" }
  let(:tenant_creator) { double("TenantCreator") }
  let(:mock_connection) { double("Faraday::Connection") }
  let(:mock_request) { double("Faraday::Request") }
  
  let(:client) do
    ScormEngine::Client.new(tenant: tenant_name, tenant_creator: tenant_creator)
  end

  before do
    allow(client).to receive(:connection).and_return(mock_connection)
    allow(mock_connection).to receive(:get).and_yield(mock_request)
    allow(mock_request).to receive(:headers).and_return({})
    allow(mock_request).to receive(:url)
  end

  describe "when tenant does not exist" do
    let(:tenant_not_found_response) do
      double("Response", 
        status: 400, 
        success?: false,
        body: { "message" => "test-tenant is not a valid tenant name" }
      )
    end

    context "with tenant_creator provided" do
      it "attempts to create the tenant and retry the request" do
        # First request fails with tenant not found
        expect(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        
        # Tenant creator is called
        expect(tenant_creator).to receive(:call).with(tenant_name)
        
        # Second request succeeds
        success_response = double("Response", status: 200, success?: true, body: {})
        expect(client).to receive(:make_request).and_call_original
        expect(client).to receive(:make_request).and_return(success_response)
        
        # Make the request
        response = client.send(:request, :get, "courses", {})
        
        expect(response).to be_a(ScormEngine::Response)
        expect(response.raw_response).to eq(success_response)
      end

      it "returns original error if tenant creation fails" do
        # First request fails with tenant not found
        expect(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        
        # Tenant creator fails
        expect(tenant_creator).to receive(:call).with(tenant_name).and_raise(StandardError.new("Creation failed"))
        
        # Make the request
        response = client.send(:request, :get, "courses", {})
        
        expect(response).to be_a(ScormEngine::Response)
        expect(response.raw_response).to eq(tenant_not_found_response)
      end

      it "only attempts tenant creation once per request" do
        # First request fails with tenant not found
        expect(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        
        # Tenant creator is called once
        expect(tenant_creator).to receive(:call).with(tenant_name).once
        
        # Second request also fails (simulate creation didn't work)
        expect(client).to receive(:make_request).and_call_original
        expect(client).to receive(:make_request).and_return(tenant_not_found_response)
        
        # Make the request
        response = client.send(:request, :get, "courses", {})
        
        expect(response).to be_a(ScormEngine::Response)
        expect(response.raw_response).to eq(tenant_not_found_response)
      end
    end

    context "without tenant_creator" do
      let(:client) { ScormEngine::Client.new(tenant: tenant_name) }

      it "returns the original error without attempting creation" do
        expect(mock_connection).to receive(:get).and_return(tenant_not_found_response)
        
        # Make the request
        response = client.send(:request, :get, "courses", {})
        
        expect(response).to be_a(ScormEngine::Response)
        expect(response.raw_response).to eq(tenant_not_found_response)
      end
    end
  end

  describe "#should_retry_with_tenant_creation?" do
    it "detects tenant not found errors correctly" do
      tenant_error = double("Response", status: 400, body: "test-tenant is not a valid tenant name")
      wrapped_response = ScormEngine::Response.new(raw_response: tenant_error)
      
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be true
    end

    it "does not trigger on other 400 errors" do
      other_error = double("Response", status: 400, body: "Some other validation error")
      wrapped_response = ScormEngine::Response.new(raw_response: other_error)
      
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
    end

    it "does not trigger on non-400 errors" do
      server_error = double("Response", status: 500, body: "Internal server error")
      wrapped_response = ScormEngine::Response.new(raw_response: server_error)
      
      expect(client.send(:should_retry_with_tenant_creation?, wrapped_response)).to be false
    end
  end
end
