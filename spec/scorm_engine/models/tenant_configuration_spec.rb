RSpec.describe ScormEngine::Models::TenantConfiguration do
  describe ".new_from_api" do
    describe ":settings" do
      it "a hash built from configurationItems" do
        config_items = [{ "id" => "Foo", "value" => "YES" }, { "id" => "Bar", "value" => "123" }]
        config = described_class.new_from_api("configurationItems" => config_items)

        expect(config.settings).to include("Foo" => "YES", "Bar" => "123")
      end
    end
  end
end
