RSpec.describe ScormEngine::Api::Endpoints::Configuration do
  describe "#get_app_configuration" do
    let(:client) { scorm_engine_client.get_app_configuration }

    it "is successful" do
      expect(client.success?).to eq true
    end

    it "returns settings and values" do
      aggregate_failures do
        expect(client.result.UserCountReportLookBackDays).to be_truthy
        expect(client.result["UserCountReportDaysBetweenReports"]).to be_truthy
      end
    end

    describe "includeMetadata" do
      let(:client) { scorm_engine_client.get_app_configuration(includeMetadata: true) }

      it "is successful" do
        expect(client.success?).to eq true
      end

      it "returns metadata in raw_response when included in options" do
        expect(client.raw_response.body["settingItems"].first["metadata"]).not_to be_nil
      end
    end
  end

  describe "#post_app_configuration" do
    let(:client) { scorm_engine_client }
    let(:response) {
      client.post_app_configuration(
        settings: { "UserCountReportLookBackDays" => "90",
                    "UserCountReportDaysBetweenReports" => 20 }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings, default params" do
      response # trigger the api
      configuration = client.get_app_configuration.result
      aggregate_failures do
        expect(configuration["UserCountReportLookBackDays"]).to eq "90"
        expect(configuration["UserCountReportDaysBetweenReports"]).to eq "20"
      end
    end

    it "persists the settings, modified params" do
      response # trigger the api

      client.post_app_configuration(
        settings: { "UserCountReportLookBackDays" => "365",
                    "UserCountReportDaysBetweenReports" => 30 }
      )

      sleep 3 # there seems to be a delay between posting new values and when they're updated frd

      configuration = client.get_app_configuration.result
      aggregate_failures do
        expect(configuration["UserCountReportLookBackDays"]).to eq "365"
        expect(configuration["UserCountReportDaysBetweenReports"]).to eq "30"
      end
    end

    it "fails when settings are invalid" do
      response = client.post_app_configuration(settings: { "NonExistentSettingTotesBogus" => "YES" })
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/NonExistentSettingTotesBogus is not a valid setting ID/)
      end
    end
  end

  describe "#delete_app_configuration" do
    let(:client) { scorm_engine_client }
    let(:response) {
      client.delete_app_configuration(setting_id: "UserCountReportLookBackDays")
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "fails when settings are invalid" do
      response = client.delete_app_configuration(setting_id: "NonExistentSettingTotesBogus")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/NonExistentSettingTotesBogus/)
      end
    end
  end
end
