RSpec.describe ScormEngine::Configuration do
  before do
    ScormEngine.configure do |config|
      config.host = "scorm.engine"
      config.username = "admin"
      config.password = "secret"
    end
  end

  it "knows its host" do
    expect(ScormEngine.configuration.host).to eq "scorm.engine"
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

  it "knows its log options" do
    expect(ScormEngine.configuration.log_options).to eq({ headers: false, bodies: false })
  end

  describe "path_prefix" do
    it "knows the default" do
      expect(ScormEngine.configuration.path_prefix).to eq "/ScormEngineInterface/api/v1/"
    end

    it "can be overridden" do
      ScormEngine.configure { |c| c.path_prefix = "/foo/bar/" }
      expect(ScormEngine.configuration.path_prefix).to eq "/foo/bar/"
    end
  end

  describe "protocol" do
    it "knows the default" do
      expect(ScormEngine.configuration.protocol).to eq "https"
    end

    it "can be overridden" do
      ScormEngine.configure { |c| c.protocol = "http" }
      expect(ScormEngine.configuration.protocol).to eq "http"
    end
  end
end
