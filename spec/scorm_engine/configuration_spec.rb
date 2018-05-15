RSpec.describe ScormEngine::Configuration do
  before do
    ScormEngine.configure do |config|
      config.base_url = "https://scorm.engine/ScormEngineInterface/api/v1"
      config.username = "admin"
      config.password = "secret"
    end
  end

  it "knows its base url" do
    expect(ScormEngine.configuration.base_url).to eq "https://scorm.engine/ScormEngineInterface/api/v1"
  end

  it "knows its username" do
    expect(ScormEngine.configuration.username).to eq "admin"
  end

  it "knows its password" do
    expect(ScormEngine.configuration.password).to eq "secret"
  end

  it "knows its logger" do
    expect(ScormEngine.configuration.logger).to be_a Logger
  end
end
