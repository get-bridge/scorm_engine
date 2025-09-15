# rubocop:disable RSpec/ExampleLength
RSpec.describe ScormEngine::Api::Endpoints::Courses::Configuration do
  subject(:client) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: client, course_id: "testing-golf-explained")
    end
  end

  describe "#get_course_configuration" do
    let(:response) { client.get_course_configuration(course_id: "testing-golf-explained") }

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
      response = client.get_course_configuration(course_id: "nonexistent-course")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/'nonexistent-course'/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#post_course_configuration" do
    let(:response) {
      client.post_course_configuration(
        course_id: "testing-golf-explained",
        settings: { "PlayerCaptureHistoryDetailed" => "NO",
                    "PlayerStatusRollupModeThresholdScore" => 80 }
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings, default params" do
      response # trigger the api
      configuration = client.get_course_configuration(course_id: "testing-golf-explained").result
      aggregate_failures do
        expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "NO"
        expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "80"
      end
    end

    it "persists the settings, modified params" do
      response # trigger the api

      client.post_course_configuration(
        course_id: "testing-golf-explained",
        settings: { "PlayerCaptureHistoryDetailed" => "YES",
                    "PlayerStatusRollupModeThresholdScore" => 42 }
      )

      configuration = client.get_course_configuration(course_id: "testing-golf-explained").result
      aggregate_failures do
        expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "YES"
        expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "42"
      end
    end

    it "fails when id is invalid" do
      response = client.post_course_configuration(course_id: "nonexistent-course", settings: {})
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/'nonexistent-course'/)
      end
    end

    it "fails when settings are invalid" do
      response = client.post_course_configuration(course_id: "testing-golf-explained", settings: { "NonExistentSettingTotesBogus" => "YES" })
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/NonExistentSettingTotesBogus/)
      end
    end
  end

  describe "#get_course_configuration_setting" do
    let(:response) {
      client.put_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore", value: 42)
      client.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore")
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns the value as a string" do
        expect(response.result).to eq "42"
      end
    end

    it "fails when course_id is invalid" do
      response = client.get_course_configuration_setting(course_id: "nonexistent-course", setting_id: "PlayerStatusRollupModeThresholdScore")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/'nonexistent-course'/)
        expect(response.result).to eq nil
      end
    end

    it "fails when setting_id is invalid" do
      response = client.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "NonExistentSettingTotesBogus")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#put_course_configuration_setting" do
    let(:value) { client.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore").result }
    let(:new_value) { (value.to_i + 1).to_s }
    let(:response) { client.put_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore", value: new_value) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "persists the changes" do
        response # trigger the api
        new_response = client.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore")
        expect(new_response.result).to eq new_value
      end
    end

    it "fails when course_id is invalid" do
      response = client.put_course_configuration_setting(course_id: "nonexistent-course", setting_id: "PlayerStatusRollupModeThresholdScore", value: "42")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/'nonexistent-course'/)
      end
    end

    it "fails when setting_id is invalid" do
      response = client.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "NonExistentSettingTotesBogus", value: "42")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
