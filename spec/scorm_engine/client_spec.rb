require "spec_helper"

RSpec.describe ScormEngine::Client do
  subject(:client) { described_class.new(tenant: tenant) }

  let(:tenant) { "test-tenant" }

  describe "#initialize" do
    it "sets the tenant" do
      expect(client.tenant).to eq(tenant)
    end

    it "defaults to API version 2" do
      expect(client.current_api_version).to eq(2)
    end

    context "with tenant_creator provided" do
      let(:tenant_creator) { instance_spy("TenantCreator") }
      let(:client_with_creator) { described_class.new(tenant: tenant, tenant_creator: tenant_creator) }

      it "sets the tenant_creator" do
        expect(client_with_creator.tenant_creator).to eq(tenant_creator)
      end

      it "stores the tenant_creator for later use" do
        expect(client_with_creator.instance_variable_get(:@tenant_creator)).to eq(tenant_creator)
      end
    end

    context "without tenant_creator" do
      it "sets tenant_creator to nil" do
        expect(client.tenant_creator).to be_nil
      end
    end
  end

  describe "#current_api_version" do
    context "when initialized with default settings" do
      it "returns 2" do
        expect(client.current_api_version).to eq(2)
      end
    end

    context "when @api_version is explicitly set" do
      before { client.instance_variable_set(:@api_version, 1) }

      it "returns the set version" do
        expect(client.current_api_version).to eq(1)
      end
    end

    context "when @api_version is nil" do
      before { client.instance_variable_set(:@api_version, nil) }

      it "returns 2 as default" do
        expect(client.current_api_version).to eq(2)
      end
    end
  end

  describe "API version migration" do
    it "uses API v2 by default for new instances" do
      new_client = described_class.new(tenant: "another-tenant")
      expect(new_client.current_api_version).to eq(2)
    end
  end
end
