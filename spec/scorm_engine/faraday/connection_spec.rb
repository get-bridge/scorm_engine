RSpec.describe ScormEngine::Faraday::Connection do
  before do
    ScormEngine.configure do |config|
      config.host = "scorm.engine"
      config.username = "admin"
      config.password = "secret"
    end
  end

  describe "#base_uri" do
    let(:uri) { scorm_engine_client.base_uri }

    it "returns a URI::HTTPS instance" do
      expect(uri).to be_a(URI::HTTPS)
    end

    it "is correct given the configuration" do
      expect(uri.to_s).to eq "https://scorm.engine/ScormEngineInterface/api/v1/"
    end
  end
end
