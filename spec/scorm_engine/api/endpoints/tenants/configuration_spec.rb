#
# NOTE: This spec will only run if a real scorm engine is available!
#       This is because the results returned expose sensitive information
#       and we'd rather they not get cached to VCR fixtures.
#
RSpec.describe ScormEngine::Api::Endpoints::Tenants::Configuration do
  around do |example|
    if scorm_engine_is_available?
      VCR.turned_off do
        example.run
      end
    else
      warn "Not running because SCORM engine is not truly available."
    end
  end

  let(:subject) { scorm_engine_client }

  describe "#get_tenant_configuration" do
    let(:response) { subject.get_tenant_configuration }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "makes settings available as key/value pairs" do
        settings = response.result.settings
        aggregate_failures do
          # just a sampling
          expect(settings.key?("ApiPostbackTimeoutSeconds")).to be_truthy
          expect(settings.key?("ApiUseSignedLaunchLinks")).to be_truthy
        end
      end
    end
  end

  describe "#post_tenant_configuration" do
    let(:response) {
      subject.post_tenant_configuration(
        settings: { "ApiPostbackTimeoutSeconds" => "15",
                    "ApiUseSignedLaunchLinks" => "true" }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings" do
      response # trigger the api
      sleep 30

      configuration = subject.get_tenant_configuration.result
      expect(configuration.settings["ApiPostbackTimeoutSeconds"]).to eq "15"
      expect(configuration.settings["ApiUseSignedLaunchLinks"]).to eq "true"

      subject.post_tenant_configuration(
        settings: { "ApiPostbackTimeoutSeconds" => "20",
                    "ApiUseSignedLaunchLinks" => "false" }
      )
      sleep 30

      configuration = subject.get_tenant_configuration.result
      expect(configuration.settings["ApiPostbackTimeoutSeconds"]).to eq "20"
      expect(configuration.settings["ApiUseSignedLaunchLinks"]).to eq "false"
    end

    it "fails when settings are invalid" do
      response = subject.post_tenant_configuration(settings: { "NonExistentSettingTotesBogus" => "YES" })
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/NonExistentSettingTotesBogus/)
    end
  end

  describe "#get_tenant_configuration_setting" do
    let(:response) {
      subject.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 42)
      sleep 30
      subject.get_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds")
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns the value as a string" do
        expect(response.result).to eq "42"
      end
    end

    it "fails when setting_id is invalid" do
      response = subject.get_tenant_configuration_setting(setting_id: "NonExistentSettingTotesBogus")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      expect(response.result).to eq nil
    end
  end

  describe "#put_tenant_configuration_setting" do
    let(:response) { subject.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 99) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "persists the changes" do
        response # trigger the api
        subject.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 100)
        new_response = subject.get_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds")
        expect(new_response.result).to eq "100"
      end
    end

    it "fails when setting_id is invalid" do
      response = subject.get_tenant_configuration_setting(setting_id: "NonExistentSettingTotesBogus", value: "42")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end
end
