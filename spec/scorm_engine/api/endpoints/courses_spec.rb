RSpec.describe ScormEngine::Api::Endpoints::Courses do
  let(:subject) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: "testing-golf-explained")
    end
  end

  describe "#courses" do
    let(:courses) { subject.courses }

    it "is successful" do
      expect(courses.success?).to eq true
    end

    describe "results" do
      it "is an enumerator of Course models" do
        expect(courses.results).to be_a Enumerator
        expect(courses.results.first).to be_a ScormEngine::Models::Course
      end

      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = courses.results.detect {|c| c.id == "testing-golf-explained" }
          expect(course.version).to be >= 0
          expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
          expect(course.registration_count).to eq 0
          expect(course.updated).to be_a Time
          expect(course.description).to eq nil
        end
      end
    end

    describe ":course_id option" do
      it "fetches a single course, but perhaps multiple versions" do
        response = subject.courses(course_id: "testing-golf-explained")
        expect(response.results.all? { |c| c.title == "Golf Explained - Run-time Basic Calls" }).to eq true
      end

      it "returns 404 when ID is invalid" do
        response = subject.courses(course_id: "invalid-bogus")
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/External Package ID 'invalid-bogus'/)
      end
    end

    describe ":since option" do
      it "works" do
        courses = subject.courses(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(courses.success?).to eq true
          expect(courses.results.to_a.size).to be >= 0
        end
      end

      it "fails when passed an invalid value" do
        courses = subject.courses(since: "invalid")
        aggregate_failures do
          expect(courses.success?).to eq false
          expect(courses.status).to eq 400
          expect(courses.results.to_a).to eq []
          expect(courses.message).to match(/'invalid' is either not a timestamp or seems to be not formatted according to ISO 8601/)
        end
      end
    end

    describe ":more option (pagination)" do
      before do
        against_real_scorm_engine do
          11.times do |idx|
            ensure_course_exists(client: subject, course_id: "paginated-course-#{idx}")
          end
        end
      end

      it "returns the :more key in the raw response" do
        expect(subject.courses.raw_response.body["more"]).to match(%r{https?://.*&more=.+})
      end

      it "returns all the courses" do
        expect(subject.courses.results.to_a.size).to be >= 11 # there may be other ones beyond those we just added
      end
    end
  end

  describe "#delete_course" do
    before do
      against_real_scorm_engine do
        ensure_course_exists(client: subject, course_id: "course-to-be-deleted")
      end
    end

    it "works" do
      response = subject.delete_course(course_id: "course-to-be-deleted")
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end

    it "raises ArgumentError when :course_id is missing" do
      expect { subject.delete_course }.to raise_error(ArgumentError, /:course_id missing/)
    end

    it "fails when id is invalid" do
      response = subject.delete_course(course_id: "nonexistent-course")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end
  end

  describe "#course_detail" do
    let(:response) { subject.course_detail(course_id: "testing-golf-explained") }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = response.result
          expect(course.version).to be >= 0
          expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
          # See https://basecamp.com/2819363/projects/15019959/messages/78805588
          # expect(course.registration_count).to eq 0
          # expect(course.updated).to be_a Time
          expect(course.description).to eq nil
        end
      end
    end
  end

  describe "#course_preview" do
    let(:response) { subject.course_preview(course_id: "testing-golf-explained", redirect_on_exit_url: "https://example.com") }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns a URL string" do
        url = response.result
        expect(url).to match(%r{/defaultui/launch.jsp\?.*testing-golf-explained.*RedirectOnExitUrl=https%3A%2F%2Fexample.com})
      end
    end

    it "fails when id is invalid" do
      response = subject.course_preview(course_id: "nonexistent-course")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
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

  describe "#set_course_configuration" do
    let(:response) { 
      subject.set_course_configuration(
        course_id: "testing-golf-explained", 
        settings: {"PlayerCaptureHistoryDetailed" => "NO",
                   "PlayerStatusRollupModeThresholdScore" => 80}
      )
    }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "persists the settings" do
      response # trigger the setting
      configuration = subject.get_course_configuration(course_id: "testing-golf-explained").result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "NO"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "80"

      subject.set_course_configuration(
        course_id: "testing-golf-explained", 
        settings: {"PlayerCaptureHistoryDetailed" => "YES",
                   "PlayerStatusRollupModeThresholdScore" => 42}
      )

      configuration = subject.get_course_configuration(course_id: "testing-golf-explained").result
      expect(configuration.settings["PlayerCaptureHistoryDetailed"]).to eq "YES"
      expect(configuration.settings["PlayerStatusRollupModeThresholdScore"]).to eq "42"
    end

    it "fails when id is invalid" do
      response = subject.set_course_configuration(course_id: "nonexistent-course", settings: {})
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end

    it "fails when settings are invalid" do
      response = subject.set_course_configuration(course_id: "testing-golf-explained", settings: {"NonExistentSettingTotesBogus" => "YES"})
      expect(response.success?).to eq false
      expect(response.status).to eq 400
      expect(response.message).to match(/No configuration setting found with id.*NonExistentSettingTotesBogus/)
    end
  end

  describe "#course_import" do
    it "raises ArgumentError when :course is missing" do
      expect { subject.course_import }.to raise_error(ArgumentError, /:course_id missing/)
    end

    it "raises ArgumentError when :url is missing" do
      expect { subject.course_import(course_id: "id123") }.to raise_error(ArgumentError, /:url missing/)
    end

    describe "arguments posted to the api" do
      it "works in the general case" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: false}, {url: "http://path.to/scorm.zip", courseName: "id123"})
        subject.course_import(course_id: "id123", url: "http://path.to/scorm.zip")
      end

      it "allows creating a new version" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: true}, {url: "http://path.to/scorm.zip", courseName: "id123"})
        subject.course_import(course_id: "id123", url: "http://path.to/scorm.zip", may_create_new_version: true)
      end

      it "allows overriding course name" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: false}, {url: "http://path.to/scorm.zip", courseName: "the name"})
        subject.course_import(course_id: "id123", url: "http://path.to/scorm.zip", name: "the name")
      end
    end

    describe "successful imports" do
      it "works" do
        import = subject.course_import(course_id: "testing123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip", may_create_new_version: true)

        aggregate_failures do
          expect(import.success?).to eq true
          expect(import.result.running?).to eq true
          expect(import.result.id).to match(/^[-a-f0-9]+$/)
        end
      end
    end

    describe "unsuccessful imports" do
      it "fails to import a previously existing course" do
        against_real_scorm_engine { ensure_course_exists(client: subject, course_id: "a-previously-existing-course", may_create_new_version: true) }
        import = import_course(client: subject, course_id: "a-previously-existing-course", may_create_new_version: false)

        aggregate_failures do
          expect(import.success?).to eq false
          expect(import.result).to eq nil
          expect(import.message).to match(/A course already exists with the specified id: .*\|a-previously-existing-course!/)
        end
      end
    end
  end

  describe "#course_import_status" do
    describe "successful imports" do
      it "works" do
        import = import_course(client: subject, course_id: "a-valid-course-url")
        import_status = subject.course_import_status(id: import.result.id)

        aggregate_failures do
          expect(import_status.success?).to eq true
          expect(import_status.result.complete?).to eq true
          expect(import_status.result.course).to be_a ScormEngine::Models::Course
          expect(import_status.result.course.id).to eq "a-valid-course-url"
        end
      end
    end

    describe "unsuccessful imports" do
      it "fails to import given an invalid url" do
        import = import_course(client: subject, course_id: "an-invalid-course-url", key: "non-existent-key")
        import_status = subject.course_import_status(id: import.result.id)

        aggregate_failures do
          expect(import_status.success?).to eq true
          expect(import_status.result.error?).to eq true
          expect(import_status.result.course).to eq nil
        end
      end
    end
  end
end
