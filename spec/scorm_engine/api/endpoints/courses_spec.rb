RSpec.describe ScormEngine::Api::Endpoints::Courses do
  let(:subject) { scorm_engine_client }

  describe "#courses" do
    let(:courses) { subject.courses }

    it "is successful" do
      expect(courses.success?).to eq true
    end

    describe "results" do
      it "is an array of Course models" do
        expect(courses.results).to be_a Array
        expect(courses.results.first).to be_a ScormEngine::Models::Course
      end

      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = courses.results.first
          expect(course.id).to eq "687b9565-fed2-4281-ba0a-0ddb72468e6b"
          expect(course.version).to eq 0
          expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
          expect(course.registration_count).to eq 1
          expect(course.updated).to eq Time.parse("2018-05-31 18:00:17.000000000 +0000")
          expect(course.description).to eq nil
        end
      end
    end

    describe ":id option" do
      it "fetches a single course" do
        courses = subject.courses(id: "687b9565-fed2-4281-ba0a-0ddb72468e6b")
        course = courses.results.first
        expect(course.id).to eq "687b9565-fed2-4281-ba0a-0ddb72468e6b"
        expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
      end
    end

    describe ":since option" do
      it "works" do
        courses = subject.courses(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(courses.success?).to eq true
          expect(courses.results.size).to be >= 0
        end
      end

      it "fails when passed an invalid value" do
        courses = subject.courses(since: "invalid")
        aggregate_failures do
          expect(courses.success?).to eq false
          expect(courses.status).to eq 400
          expect(courses.results).to eq []
          expect(courses.message).to match(/'invalid' is either not a timestamp or seems to be not formatted according to ISO 8601/)
        end
      end
    end

    describe ":more option" do
      pending "Can't test until we have enough results to paginate. I think?"
    end
  end

  describe "#course_import" do
    it "raises ArgumentError when :course is missing" do
      expect { subject.course_import }.to raise_error(ArgumentError, /:course missing/)
    end

    it "raises ArgumentError when :url is missing" do
      expect { subject.course_import(course: "id123") }.to raise_error(ArgumentError, /:url missing/)
    end

    describe "arguments posted to the api" do
      it "works in the general case" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: false}, {url: "http://path.to/scorm.zip", courseName: "id123"})
        subject.course_import(course: "id123", url: "http://path.to/scorm.zip")
      end

      it "allows creating a new version" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: true}, {url: "http://path.to/scorm.zip", courseName: "id123"})
        subject.course_import(course: "id123", url: "http://path.to/scorm.zip", may_create_new_version: true)
      end

      it "allows overriding course name" do
        expect(subject).to receive(:post).with("courses/importJobs", {course: "id123", mayCreateNewVersion: false}, {url: "http://path.to/scorm.zip", courseName: "the name"})
        subject.course_import(course: "id123", url: "http://path.to/scorm.zip", name: "the name")
      end
    end

    describe "successful imports" do
      it "works" do
        import = subject.course_import(course: "testing123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip", may_create_new_version: true)

        aggregate_failures do
          expect(import.success?).to eq true
          expect(import.result.running?).to eq true
          expect(import.result.id).to match(/^[-a-f0-9]+$/)
        end
      end
    end

    describe "unsuccessful imports" do
      it "fails to import a previously existing course" do
        subject.course_import(course: "testing123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip", may_create_new_version: true)
        import = subject.course_import(course: "testing123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip", may_create_new_version: false)

        aggregate_failures do
          expect(import.success?).to eq false
          expect(import.result).to eq nil
          expect(import.message).to match(/A course already exists with the specified id: .*\|testing123!/)
        end
      end
    end
  end

  describe "#course_import_status" do
    describe "successful imports" do
      it "works" do
        import = subject.course_import(course: "valid123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip", may_create_new_version: true)
        sleep 20 if recording_vcr?
        import_status = subject.course_import_status(id: import.result.id)

        aggregate_failures do
          expect(import_status.success?).to eq true
          expect(import_status.result.complete?).to eq true
          expect(import_status.result.course).to be_a ScormEngine::Models::Course
          expect(import_status.result.course.id).to eq "valid123"
        end
      end
    end

    describe "unsuccessful imports" do
      it "fails to import given an invalid url" do
        import = subject.course_import(course: "invalid123", url: "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/invalid.zip", may_create_new_version: true)
        sleep 20 if recording_vcr?
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
