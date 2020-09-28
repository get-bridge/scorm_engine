RSpec.describe ScormEngine::Api::Endpoints::Registrations do
  let(:subject) { scorm_engine_client }

  let(:registration_options) { {
    course_id: "testing-golf-explained",
    registration_id: "testing-golf-explained-registration-1",
    learner: {
      id: "testing-golf-explained-learner-1",
      first_name: "Arnold",
      last_name: "Palmer",
    },
    post_back: {
      url: "http://playtronics.com/passback/",
      auth_type: "form",
      user_name: "werner_brandes",
      password: "passport",
      results_format: "activity",
    },
  } }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: registration_options[:course_id])
      ensure_registration_exists(registration_options.merge(client: subject))
      ensure_course_exists(client: subject, course_id: registration_options[:course_id] + "-no-registrations")
    end
  end

  describe "#get_registrations" do
    let(:registrations) { subject.get_registrations }

    it "is successful" do
      expect(registrations.success?).to eq true
    end

    it "returns an array of registrations" do
      expect(registrations.result.all? { |r| r.is_a?(ScormEngine::Models::Registration) }).to eq true
    end

    it "includes results we expect" do
      reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
      expect(reg).not_to be nil
    end

    describe "filtering by course_id" do
      it "includes results" do
        registrations = subject.get_registrations(course_id: registration_options[:course_id])
        reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
        expect(reg).not_to be nil
      end

      it "excludes results" do
        registrations = subject.get_registrations(course_id: registration_options[:course_id] + "-no-registrations")
        reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
        expect(reg).to be nil
      end
    end

    describe "filtering by learner_id" do
      it "includes results" do
        registrations = subject.get_registrations(learner_id: registration_options[:learner][:id])
        reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
        expect(reg).not_to be nil
      end

      it "excludes results" do
        registrations = subject.get_registrations(learner_id: "some-other-learner-id")
        reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
        expect(reg).to be nil
      end
    end
  end

  describe "#get_registration_instances" do
    let(:registrations) { subject.get_registration_instances(registration_id: registration_options[:registration_id]) }

    it "is successful" do
      expect(registrations.success?).to eq true
    end

    it "returns an array of registrations" do
      expect(registrations.result.all? { |r| r.is_a?(ScormEngine::Models::Registration) }).to eq true
    end

    it "includes results we expect" do
      reg = registrations.result.detect { |r| r.id == registration_options[:registration_id] }
      expect(reg).not_to be nil
    end
  end

  describe "#get_registration_exists" do
    it "is true when registration exists" do
      response = subject.get_registration_exists(registration_id: registration_options[:registration_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.result).to eq true
      end
    end

    it "is false when registration does not exist" do
      response = subject.get_registration_exists(registration_id: "reg-does-not-exist")
      aggregate_failures do
        expect(response.result).to eq nil
        expect(response.status).to eq 404
      end
    end
  end

  describe "#get_registration_progress" do
    it "returns a registration when it exists" do
      response = subject.get_registration_progress(registration_id: registration_options[:registration_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.result).to be_a ScormEngine::Models::Registration
        expect(response.result.id).to eq registration_options[:registration_id]
      end
    end

    it "fails when registration does not exist" do
      response = subject.get_registration_progress(registration_id: "reg-does-not-exist")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.result).to eq nil
      end
    end

    context "detail" do
      it "does not return activity_details by default" do
        response = subject.get_registration_progress(registration_id: registration_options[:registration_id])
        expect(response.result.activity_details).to eq nil
      end

      it "returns activity_details if requested" do
        response = subject.get_registration_progress(registration_id: registration_options[:registration_id], detail: true)
        expect(response.result.activity_details).to be_a ScormEngine::Models::RegistrationActivityDetail
      end
    end
  end

  describe "#delete_registration" do
    it "is successful when registration exists" do
      response = subject.delete_registration(registration_id: registration_options[:registration_id])
      aggregate_failures do
        expect(response.success?).to eq true
      end
    end

    it "is failure when registration does not exist" do
      response = subject.delete_registration(registration_id: "reg-does-not-exist")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.result).to eq nil
      end
    end
  end

  describe "#post_registration" do
    it "is successful" do
      subject.delete_registration(registration_options)
      response = subject.post_registration(registration_options)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "is successful even when given a UTF8/slashed username" do
      options = registration_options.dup
      options[:learner][:first_name] = "Släshy"
      options[:learner][:last_name] = "Mč/Slásh\Facę"
      subject.delete_registration(options)
      response = subject.post_registration(options)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "fails if course_id is invalid" do
      response = subject.post_registration(registration_options.merge(course_id: "invalid-bogus"))
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/'invalid-bogus'/)
      end
    end

    it "fails if registration_id already exists" do
      response = subject.post_registration(registration_options)
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
        expect(response.message).to match(/This RegistrationId is already in use/)
      end
    end
  end

  describe "#get_registration_launch_link" do
    let(:response) { subject.get_registration_launch_link(registration_id: registration_options[:registration_id], redirect_on_exit_url: "https://example.com") }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns a URL string" do
        url = response.result
        expect(url).to match(%r{/defaultui/launch.jsp\?.*registration=#{registration_options[:registration_id]}.*RedirectOnExitUrl=https%3A%2F%2Fexample.com})
      end
    end

    it "fails when id is invalid" do
      response = subject.get_registration_launch_link(registration_id: "nonexistent-registration")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/'nonexistent-registration'/)
      expect(response.result).to eq nil
    end
  end
end
