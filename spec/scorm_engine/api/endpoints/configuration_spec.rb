RSpec.describe ScormEngine::Api::Endpoints::Configuration do
  describe "#get_app_configuration" do
    let(:subject) { scorm_engine_client.get_app_configuration }

    it "is successful" do
      expect(subject.success?).to eq true
    end

    it "returns settings and values" do
      expect(subject.result.UserCountReportLookBackDays).to be_truthy
      expect(subject.result["UserCountReportDaysBetweenReports"]).to be_truthy
    end

    describe "includeMetadata" do
      let(:subject) { scorm_engine_client.get_app_configuration(includeMetadata: true) }

      it "is successful" do
        expect(subject.success?).to eq true
      end

      it "returns metadata in raw_response when included in options" do
        expect(subject.raw_response.body['settingItems'].first["metadata"]).to_not be_nil
      end
    end
  end

  describe "#post_app_configuration" do
    let(:subject) { scorm_engine_client }
    let(:response) {
      subject.post_app_configuration(
        settings: { "UserCountReportLookBackDays" => "90",
                    "UserCountReportDaysBetweenReports" => 20 }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings" do
      response # trigger the api
      configuration = subject.get_app_configuration.result
      expect(configuration["UserCountReportLookBackDays"]).to eq "90"
      expect(configuration["UserCountReportDaysBetweenReports"]).to eq "20"

      resp = subject.post_app_configuration(
        settings: { "UserCountReportLookBackDays" => "365",
                    "UserCountReportDaysBetweenReports" => 30 }
      )

      sleep 3 # there seems to be a delay between posting new values and when they're updated frd

      configuration = subject.get_app_configuration.result
      expect(configuration["UserCountReportLookBackDays"]).to eq "365"
      expect(configuration["UserCountReportDaysBetweenReports"]).to eq "30"
    end

    it "fails when settings are invalid" do
      response = subject.post_app_configuration(settings: { "NonExistentSettingTotesBogus" => "YES" })
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/NonExistentSettingTotesBogus is not a valid setting ID/)
    end
  end

  describe "#delete_app_configuration" do
    let(:subject) { scorm_engine_client }
    let(:response) {
      subject.delete_app_configuration(setting_id: "UserCountReportLookBackDays")
    }

    it "is successful" do
      expect(response.success?).to eq true
    end
    it "fails when settings are invalid" do
      response = subject.delete_app_configuration(setting_id: "NonExistentSettingTotesBogus")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/NonExistentSettingTotesBogus/)
    end
  end
end
