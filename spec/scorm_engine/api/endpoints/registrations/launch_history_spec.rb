RSpec.describe ScormEngine::Api::Endpoints::Registrations::LaunchHistory do
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
      # NOTE: For this to work you'll need to visit the launch URL at least once manually
      #       so that we have something to record in VCR for later.
      #
      #       subject.get_registration_launch_link(
      #         registration_id: registration_options[:registration_id]
      #       ).result
    end
  end

  describe "#get_registration_launch_history" do
    let(:histories) { subject.get_registration_launch_history(registration_id: registration_options[:registration_id]) }

    it "is successful" do
      expect(histories.success?).to eq true
    end

    it "returns an array of registration launch histories" do
      expect(histories.result.all? { |r| r.is_a?(ScormEngine::Models::RegistrationLaunchHistory) }).to eq true
    end

    it "fails when registration does not exist" do
      response = subject.get_registration_launch_history(registration_id: "reg-does-not-exist")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
      end
    end
  end
end
