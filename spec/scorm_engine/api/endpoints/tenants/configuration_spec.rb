# NOTE: This spec will only run if a real scorm engine is available!
#       This is because the results returned expose sensitive information
#       and we'd rather they not get cached to VCR fixtures.
#
RSpec.describe ScormEngine::Api::Endpoints::Tenants::Configuration do
  subject(:client) { scorm_engine_client }

  around do |example|
    if scorm_engine_is_available?
      VCR.turned_off { example.run }
    else
      warn "Not running because SCORM engine is not truly available."
    end
  end

  describe "#get_tenant_configuration" do
    let(:response) { client.get_tenant_configuration }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      let(:settings) { response.result.settings }

      it "has ApiPostbackTimeoutSeconds key" do
        expect(settings).to be_key("ApiPostbackTimeoutSeconds")
      end

      it "has ApiUseSignedLaunchLinks key" do
        expect(settings).to be_key("ApiUseSignedLaunchLinks")
      end
    end
  end

  describe "#post_tenant_configuration" do
    let(:response) do
      client.post_tenant_configuration(
        settings: {
          "ApiPostbackTimeoutSeconds" => "15",
          "ApiUseSignedLaunchLinks" => "true"
        }
      )
    end

    it "is successful" do
      expect(response.success?).to eq true
    end

    context "when persisting settings" do
      before do
        response
        sleep 30
      end

      it "persists ApiPostbackTimeoutSeconds" do
        configuration = client.get_tenant_configuration.result
        expect(configuration.settings["ApiPostbackTimeoutSeconds"]).to eq "15"
      end

      it "persists ApiUseSignedLaunchLinks" do
        configuration = client.get_tenant_configuration.result
        expect(configuration.settings["ApiUseSignedLaunchLinks"]).to eq "true"
      end
    end

    context "when updating settings" do
      before do
        client.post_tenant_configuration(
          settings: {
            "ApiPostbackTimeoutSeconds" => "20",
            "ApiUseSignedLaunchLinks" => "false"
          }
        )
        sleep 30
      end

      it "updates ApiPostbackTimeoutSeconds" do
        configuration = client.get_tenant_configuration.result
        expect(configuration.settings["ApiPostbackTimeoutSeconds"]).to eq "20"
      end

      it "updates ApiUseSignedLaunchLinks" do
        configuration = client.get_tenant_configuration.result
        expect(configuration.settings["ApiUseSignedLaunchLinks"]).to eq "false"
      end
    end

    describe "invalid settings" do
      let(:invalid_response) do
        client.post_tenant_configuration(settings: { "NonExistentSettingTotesBogus" => "YES" })
      end

      it "returns unsuccessful response" do
        expect(invalid_response.success?).to eq false
      end

      it "returns 400 status" do
        expect(invalid_response.status).to eq 400
      end

      it "returns error message" do
        expect(invalid_response.message).to match(/NonExistentSettingTotesBogus/)
      end
    end
  end

  describe "#get_tenant_configuration_setting" do
    let(:response) do
      client.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 42)
      sleep 30
      client.get_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds")
    end

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "returns the value as a string" do
      expect(response.result).to eq "42"
    end

    context "when setting_id is invalid" do
      let(:invalid_response) do
        client.get_tenant_configuration_setting(setting_id: "NonExistentSettingTotesBogus")
      end

      it "is unsuccessful" do
        expect(invalid_response.success?).to eq false
      end

      it "returns 400 status" do
        expect(invalid_response.status).to eq 400
      end

      it "returns error message" do
        expect(invalid_response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      end

      it "returns nil result" do
        expect(invalid_response.result).to eq nil
      end
    end
  end

  describe "#put_tenant_configuration_setting" do
    let(:response) { client.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 99) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the changes" do
      response # trigger the api
      client.put_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds", value: 100)
      new_response = client.get_tenant_configuration_setting(setting_id: "ApiPostbackTimeoutSeconds")
      expect(new_response.result).to eq "100"
    end

    context "when setting_id is invalid" do
      let(:invalid_response) do
        client.get_tenant_configuration_setting(setting_id: "NonExistentSettingTotesBogus", value: "42")
      end

      it "is unsuccessful" do
        expect(invalid_response.success?).to eq false
      end

      it "returns 400 status" do
        expect(invalid_response.status).to eq 400
      end

      it "returns error message" do
        expect(invalid_response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      end
    end
  end
end
