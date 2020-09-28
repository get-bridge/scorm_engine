RSpec.describe ScormEngine::Api::Endpoints::Registrations::Configuration do
  let(:subject) { scorm_engine_client }

  let(:registration_options) { {
    course_id: "testing-golf-explained",
    registration_id: "testing-golf-explained-registration-1",
    learner: {
      id: "testing-golf-explained-learner-1",
      first_name: "Arnold",
      last_name: "Palmer",
    }
  } }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: registration_options[:course_id])
      ensure_registration_exists(registration_options.merge(client: subject))
    end
  end

  describe "#get_registration_configuration" do
    let(:response) { subject.get_registration_configuration(registration_id: registration_options[:registration_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "makes settings available as key/value pairs" do
        settings = response.result.settings
        aggregate_failures do
          # just a sampling
          expect(settings.key?("PlayerStatusRollupModeValue")).to be_truthy
          expect(settings.key?("PlayerLaunchType")).to be_truthy
        end
      end
    end

    it "fails when id is invalid" do
      response = subject.get_registration_configuration(registration_id: "nonexistent-registration", settings: {})
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
      expect(response.result).to eq nil
    end
  end

  describe "#post_registration_configuration" do
    let(:response) {
      subject.post_registration_configuration(
        registration_id: registration_options[:registration_id],
        settings: { "PlayerCaptureHistoryDetailed" => "NO",
                    "PlayerStatusRollupModeThresholdScore" => 80 }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings" do
      response # trigger the api
      configuration = subject.get_registration_configuration(registration_id: registration_options[:registration_id]).result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "NO"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "80"

      subject.post_registration_configuration(
        registration_id: registration_options[:registration_id],
        settings: { "PlayerCaptureHistoryDetailed" => "YES",
                    "PlayerStatusRollupModeThresholdScore" => 42 }
      )

      configuration = subject.get_registration_configuration(registration_id: registration_options[:registration_id]).result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "YES"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "42"
    end

    it "fails when id is invalid" do
      response = subject.post_registration_configuration(registration_id: "nonexistent-registration", settings: {})
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
      expect(response.result).to eq nil
    end

    it "fails when settings are invalid" do
      response = subject.post_registration_configuration(registration_id: registration_options[:registration_id], settings: { "NonExistentSettingTotesBogus" => "YES" })
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/NonExistentSettingTotesBogus/)
    end
  end

  describe "#get_registration_configuration_setting" do
    let(:response) {
      subject.put_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore", value: 42)
      subject.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore")
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns the value as a string" do
        expect(response.result).to eq "42"
      end
    end

    it "fails when registration_id is invalid" do
      response = subject.get_registration_configuration_setting(registration_id: "nonexistent-registration", setting_id: "PlayerStatusRollupModeThresholdScore")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
      expect(response.result).to eq nil
    end

    it "fails when setting_id is invalid" do
      response = subject.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "NonExistentSettingTotesBogus")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end

  describe "#put_registration_configuration_setting" do
    let(:value) { subject.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore").result }
    let(:new_value) { (value.to_i + 1).to_s }
    let(:response) { subject.put_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore", value: new_value) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "persists the changes" do
        response # trigger the api
        new_response = subject.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore")
        expect(new_response.result).to eq new_value
      end
    end

    it "fails when registration_id is invalid" do
      response = subject.put_registration_configuration_setting(registration_id: "nonexistent-registration", setting_id: "PlayerStatusRollupModeThresholdScore", value: "42")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
      expect(response.result).to eq nil
    end

    it "fails when setting_id is invalid" do
      response = subject.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "NonExistentSettingTotesBogus", value: "42")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end
end
