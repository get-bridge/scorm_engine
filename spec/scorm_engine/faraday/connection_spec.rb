RSpec.describe ScormEngine::Faraday::Connection do
  before do
    ScormEngine.configure do |config|
      config.host = "scorm.engine"
      config.username = "admin"
      config.password = "secret"
    end
  end

  describe "#base_uri" do
    {
      1 => "https://scorm.engine/ScormEngineInterface/api/v1/",
      2 => "https://scorm.engine/ScormEngineInterface/api/v2/",
    }.each do |version, expected_url|
      context "with version #{version}" do
        let(:uri) { scorm_engine_client.base_uri(version: version) }

        it "returns a URI::HTTPS instance" do
          expect(uri).to be_a(URI::HTTPS)
        end

        it "is correct given the configuration" do
          expect(uri.to_s).to eq expected_url
        end
      end
    end
  end

  describe "#connection" do
    describe "version" do
      it "passes on to #base_uri" do
        client = ScormEngine::Client.new(tenant: "test")

        expect(client).to receive(:base_uri).with(version: 2).and_call_original
        client.send(:connection, version: 2)
      end
    end
  end
end
