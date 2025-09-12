RSpec.describe ScormEngine::Models::CourseConfiguration do
  describe ".new_from_api" do
    describe ":settings" do
      it "a hash built from configurationItems value one" do
        config = described_class.new_from_api(
          "configurationItems" => [{ "id" => "Foo", "value" => "YES" }, { "id" => "Bar", "value" => "123" }]
        )
        expect(config.settings["Foo"]).to eq "YES"
      end

      it "a hash built from configurationItems value two" do
        config = described_class.new_from_api(
          "configurationItems" => [{ "id" => "Foo", "value" => "YES" }, { "id" => "Bar", "value" => "123" }]
        )
        expect(config.settings["Bar"]).to eq "123"
      end
    end
  end
end
