RSpec.describe ScormEngine::Api::Endpoints::Registrations do
  let(:subject) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: "testing-golf-explained")
    end
  end

  describe "#get_registrations" do
    let(:registrations) { subject.get_registrations }

    it "is successful" do
      expect(registrations.success?).to eq true
    end
  end
end
