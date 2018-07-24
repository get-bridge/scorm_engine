RSpec.describe ScormEngine::Api::Endpoints::Courses::Configuration do
  let(:subject) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: "testing-golf-explained")
    end
  end

  describe "#get_course_configuration" do
    let(:response) { subject.get_course_configuration(course_id: "testing-golf-explained") }

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
      response = subject.get_course_configuration(course_id: "nonexistent-course")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end
  end

  describe "#post_course_configuration" do
    let(:response) { 
      subject.post_course_configuration(
        course_id: "testing-golf-explained", 
        settings: {"PlayerCaptureHistoryDetailed" => "NO",
                   "PlayerStatusRollupModeThresholdScore" => 80}
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings" do
      response # trigger the api
      configuration = subject.get_course_configuration(course_id: "testing-golf-explained").result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "NO"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "80"

      subject.post_course_configuration(
        course_id: "testing-golf-explained", 
        settings: {"PlayerCaptureHistoryDetailed" => "YES",
                   "PlayerStatusRollupModeThresholdScore" => 42}
      )

      configuration = subject.get_course_configuration(course_id: "testing-golf-explained").result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "YES"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "42"
    end

    it "fails when id is invalid" do
      response = subject.post_course_configuration(course_id: "nonexistent-course", settings: {})
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end

    it "fails when settings are invalid" do
      response = subject.post_course_configuration(course_id: "testing-golf-explained", settings: {"NonExistentSettingTotesBogus" => "YES"})
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end

  describe "#get_course_configuration_setting" do
    let(:response) { 
      subject.put_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore", value: 42)
      subject.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore")
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
      response = subject.get_course_configuration_setting(course_id: "nonexistent-course", setting_id: "PlayerStatusRollupModeThresholdScore")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end

    it "fails when setting_id is invalid" do
      response = subject.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "NonExistentSettingTotesBogus")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end

  describe "#put_course_configuration_setting" do
    let(:value) { subject.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore").result }
    let(:new_value) { (value.to_i + 1).to_s }
    let(:response) { subject.put_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore", value: new_value) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "persists the changes" do
        response # trigger the api
        new_response = subject.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "PlayerStatusRollupModeThresholdScore")
        expect(new_response.result).to eq new_value
      end
    end

    it "fails when course_id is invalid" do
      response = subject.put_course_configuration_setting(course_id: "nonexistent-course", setting_id: "PlayerStatusRollupModeThresholdScore", value: "42")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end

    it "fails when setting_id is invalid" do
      response = subject.get_course_configuration_setting(course_id: "testing-golf-explained", setting_id: "NonExistentSettingTotesBogus", value: "42")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end
end
