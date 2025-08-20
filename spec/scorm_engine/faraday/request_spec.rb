require "spec_helper"

RSpec.describe ScormEngine::Faraday::Request do
  # Create a test class that includes the Request module
  class TestClient
    include ScormEngine::Faraday::Connection
    include ScormEngine::Faraday::Request
    
    attr_accessor :tenant
    
    def initialize(tenant: "default")
      @tenant = tenant
    end
  end
  
  subject { TestClient.new }
  
  describe "API version handling" do
    it "defaults to API version 2" do
      expect(subject.instance_variable_get(:@api_version)).to eq(2)
    end
    
    it "preserves API version when using api_v2 block" do
      # Set to v1 for testing
      subject.instance_variable_set(:@api_version, 1)
      
      subject.api_v2 do
        expect(subject.instance_variable_get(:@api_version)).to eq(2)
      end
      
      # Should be restored after the block
      expect(subject.instance_variable_get(:@api_version)).to eq(1)
    end
    
    it "preserves without_tenant flag when using api_v2 block" do
      subject.instance_variable_set(:@without_tenant, true)
      
      subject.api_v2(without_tenant: false) do
        expect(subject.instance_variable_get(:@without_tenant)).to eq(false)
      end
      
      # Should be restored after the block
      expect(subject.instance_variable_get(:@without_tenant)).to eq(true)
    end
  end
end
