# rubocop:disable RSpec/ExampleLength
RSpec.describe ScormEngine::Api::Endpoints::Registrations::Configuration do
  subject(:client) { scorm_engine_client }

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
      ensure_course_exists(client: client, course_id: registration_options[:course_id])
      ensure_registration_exists(registration_options.merge(client: client))
    end
  end

  describe "#get_registration_configuration" do
    let(:response) { client.get_registration_configuration(registration_id: registration_options[:registration_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "makes settings available as key/value pairs" do
        settings = response.result.settings
        aggregate_failures do
          # just a sampling
          expect(settings).to be_key("PlayerStatusRollupModeValue")
          expect(settings).to be_key("PlayerLaunchType")
        end
      end
    end

    it "fails when id is invalid" do
      response = client.get_registration_configuration(registration_id: "nonexistent-registration", settings: {})
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#post_registration_configuration" do
    let(:response) {
      client.post_registration_configuration(
        registration_id: registration_options[:registration_id],
        settings: { "PlayerCaptureHistoryDetailed" => "NO",
                    "PlayerStatusRollupModeThresholdScore" => 80 }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings, default params" do
      response # trigger the api
      configuration = client.get_registration_configuration(registration_id: registration_options[:registration_id]).result
      aggregate_failures do
        expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "NO"
        expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "80"
      end
    end

    it "persists the settings, modified params" do
      response # trigger the api

      client.post_registration_configuration(
        registration_id: registration_options[:registration_id],
        settings: { "PlayerCaptureHistoryDetailed" => "YES",
                    "PlayerStatusRollupModeThresholdScore" => 42 }
      )

      configuration = client.get_registration_configuration(registration_id: registration_options[:registration_id]).result
      aggregate_failures do
        expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "YES"
        expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "42"
      end
    end

    it "fails when id is invalid" do
      response = client.post_registration_configuration(registration_id: "nonexistent-registration", settings: {})
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
        expect(response.result).to eq nil
      end
    end

    it "fails when settings are invalid" do
      response = client.post_registration_configuration(registration_id: registration_options[:registration_id], settings: { "NonExistentSettingTotesBogus" => "YES" })
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/NonExistentSettingTotesBogus/)
      end
    end
  end

  describe "#get_registration_configuration_setting" do
    let(:response) {
      client.put_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore", value: 42)
      client.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore")
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
      response = client.get_registration_configuration_setting(registration_id: "nonexistent-registration", setting_id: "PlayerStatusRollupModeThresholdScore")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
        expect(response.result).to eq nil
      end
    end

    it "fails when setting_id is invalid" do
      response = client.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "NonExistentSettingTotesBogus")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      end
    end
  end

  describe "#put_registration_configuration_setting" do
    let(:value) { client.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore").result }
    let(:new_value) { (value.to_i + 1).to_s }
    let(:response) { client.put_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore", value: new_value) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "persists the changes" do
        response # trigger the api
        new_response = client.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "PlayerStatusRollupModeThresholdScore")
        expect(new_response.result).to eq new_value
      end
    end

    it "fails when registration_id is invalid" do
      response = client.put_registration_configuration_setting(registration_id: "nonexistent-registration", setting_id: "PlayerStatusRollupModeThresholdScore", value: "42")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/Registration ID 'nonexistent-registration'/)
        expect(response.result).to eq nil
      end
    end

    it "fails when setting_id is invalid" do
      response = client.get_registration_configuration_setting(registration_id: registration_options[:registration_id], setting_id: "NonExistentSettingTotesBogus", value: "42")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
