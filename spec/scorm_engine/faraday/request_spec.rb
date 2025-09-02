require_relative "../../../support/scorm_engine_configuration"

RSpec.describe ScormEngine::Faraday::Request do
  let(:tenant) { "test-tenant" }
  let(:mock_class) do
    Class.new do
      include ScormEngine::Faraday::Request
      
      attr_reader :tenant
      
      def initialize(tenant)
        @tenant = tenant
      end
      
      def current_api_version
        2  # Default API v2
      end
      
      def connection(version:)
        # Mock Faraday connection
        double("Connection").tap do |conn|
          allow(conn).to receive(:get).and_yield(double("Request").as_null_object)
          allow(conn).to receive(:post).and_yield(double("Request").as_null_object)
          allow(conn).to receive(:put).and_yield(double("Request").as_null_object)
          allow(conn).to receive(:delete).and_yield(double("Request").as_null_object)
        end
      end
      
      def base_uri
        double("URI", path: "/api/v1/")
      end
    end
  end
  
  subject { mock_class.new(tenant) }

  describe "#api_v2" do
    it "temporarily sets API version to 2" do
      expect(subject.instance_variable_get(:@api_version)).to be_nil
      
      subject.api_v2 do
        expect(subject.instance_variable_get(:@api_version)).to eq(2)
      end
    end

    it "resets API version to nil after block" do
      subject.api_v2 do
        # Inside block
      end
      
      expect(subject.instance_variable_get(:@api_version)).to be_nil
    end

    it "sets without_tenant flag when requested" do
      subject.api_v2(without_tenant: true) do
        expect(subject.instance_variable_get(:@without_tenant)).to eq(true)
      end
    end

    it "resets even if exception occurs" do
      expect {
        subject.api_v2 do
          raise "Test error"
        end
      }.to raise_error("Test error")
      
      expect(subject.instance_variable_get(:@api_version)).to be_nil
    end
  end

  describe "#api_v1" do
    it "temporarily sets API version to 1" do
      expect(subject.instance_variable_get(:@api_version)).to be_nil
      
      subject.api_v1 do
        expect(subject.instance_variable_get(:@api_version)).to eq(1)
      end
    end

    it "resets API version to nil after block (not forced to v2)" do
      subject.api_v1 do
        # Inside block
      end
      
      expect(subject.instance_variable_get(:@api_version)).to be_nil
    end

    it "resets even if exception occurs" do
      expect {
        subject.api_v1 do
          raise "Test error"
        end
      }.to raise_error("Test error")
      
      expect(subject.instance_variable_get(:@api_version)).to be_nil
    end
  end

  describe "#request" do
    let(:mock_request) { double("Request") }
    let(:mock_connection) { double("Connection") }

    before do
      allow(subject).to receive(:connection).and_return(mock_connection)
      allow(mock_connection).to receive(:get).and_yield(mock_request)
      allow(mock_request).to receive(:headers).and_return({})
      allow(mock_request).to receive(:url)
      allow(subject).to receive(:coerce_options).and_return({})
    end

    context "with API v2" do
      before do
        subject.instance_variable_set(:@api_version, 2)
      end

      it "uses current_api_version as fallback when @api_version is nil" do
        subject.instance_variable_set(:@api_version, nil)
        
        expect(subject).to receive(:connection).with(version: 2)
        
        subject.send(:request, :get, "test/path", {})
      end

      it "adds engineTenantName header for API v2" do
        expect(mock_request).to receive(:[]=).with("engineTenantName", tenant)
        
        subject.send(:request, :get, "test/path", {})
      end

      it "does not add tenant to path for API v2" do
        expect(mock_request).to receive(:url).with("test/path", {})
        
        subject.send(:request, :get, "test/path", {})
      end

      context "when without_tenant is true" do
        before do
          subject.instance_variable_set(:@without_tenant, true)
        end

        it "does not add engineTenantName header" do
          expect(mock_request).not_to receive(:[]=).with("engineTenantName", tenant)
          
          subject.send(:request, :get, "test/path", {})
        end
      end
    end

    context "with API v1" do
      before do
        subject.instance_variable_set(:@api_version, 1)
        allow(mock_connection).to receive(:get).and_yield(mock_request)
      end

      it "adds tenant to path for API v1" do
        expect(mock_request).to receive(:url).with("#{tenant}/test/path", {})
        
        subject.send(:request, :get, "test/path", {})
      end

      it "does not add engineTenantName header for API v1" do
        expect(mock_request).not_to receive(:[]=).with("engineTenantName", anything)
        
        subject.send(:request, :get, "test/path", {})
      end
    end
  end

  describe "clean design principles" do
    it "does not force API version to v2 in ensure blocks" do
      # This test ensures we maintain proper reset behavior
      original_version = subject.instance_variable_get(:@api_version)
      
      subject.api_v1 do
        # Temporarily v1
      end
      
      # Should return to original state (nil), not forced to v2
      expect(subject.instance_variable_get(:@api_version)).to eq(original_version)
    end

    it "uses current_api_version method for default fallback" do
      expect(subject).to receive(:current_api_version).and_return(2)
      
      # When @api_version is nil, should use current_api_version
      subject.send(:request, :get, "test", {})
    end
  end
end
