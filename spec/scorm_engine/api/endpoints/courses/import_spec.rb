RSpec.describe ScormEngine::Api::Endpoints::Courses::Import do
  let(:subject) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: "testing-golf-explained")
    end
  end

  describe "#post_course_import" do
    context "raising ArgumentError" do
      it "when :course is missing" do
        expect { subject.post_course_import }.to raise_error(ArgumentError, /course_id missing/)
      end

      it "when :url and :pathname are missing" do
        expect { subject.post_course_import(course_id: "id123") }.to raise_error(ArgumentError, /Exclusive option required. One of: url, pathname/)
      end

      it "when :url and :pathname are both present" do
        expect { subject.post_course_import(course_id: "id123", url: "http://path.to/scorm.zip", pathname: "/path/to/scorm.zip") }.to raise_error(ArgumentError, /Exclusive option required. One of: url, pathname/)
      end
    end

    describe "arguments posted to the api" do
      it "works in the general case" do
        expect(subject).to receive(:post).with("courses/importJobs", { course: "id123", mayCreateNewVersion: false }, { url: "http://path.to/scorm.zip", courseName: "id123" })
        subject.post_course_import(course_id: "id123", url: "http://path.to/scorm.zip")
      end

      it "allows creating a new version" do
        expect(subject).to receive(:post).with("courses/importJobs", { course: "id123", mayCreateNewVersion: true }, { url: "http://path.to/scorm.zip", courseName: "id123" })
        subject.post_course_import(course_id: "id123", url: "http://path.to/scorm.zip", may_create_new_version: true)
      end

      it "allows overriding course name" do
        expect(subject).to receive(:post).with("courses/importJobs", { course: "id123", mayCreateNewVersion: false }, { url: "http://path.to/scorm.zip", courseName: "the name" })
        subject.post_course_import(course_id: "id123", url: "http://path.to/scorm.zip", name: "the name")
      end
    end

    # Unfortunately these tests can't be done without a real scorm engine
    # available as there is no way to import a course, then later check it's
    # _final_ import status.
    describe "successful imports" do
      it "works with a :url" do
        against_real_scorm_engine do
          import = import_course(client: subject, course_id: "testing-url-123", url: "https://github.com/get-bridge/scorm_engine/raw/master/spec/fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip")
          aggregate_failures do
            expect(import.success?).to eq true
            expect(import.result.complete?).to eq true
            expect(import.result.id).to match(/^[-a-f0-9]+$/)
          end
        end
      end

      it "works with a :pathname" do
        against_real_scorm_engine do
          pathname = "#{__dir__}/../../../../fixtures/zip/RuntimeBasicCalls_SCORM20043rdEdition.zip"
          import = import_course(client: subject, course_id: "testing-pathname-123", pathname: pathname)

          aggregate_failures do
            expect(import.success?).to eq true
            expect(import.result.complete?).to eq true
            expect(import.result.id).to match(/^[-a-f0-9]+$/)
          end
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

  describe "#get_course_import" do
    describe "successful imports" do
      it "works" do
        import = import_course(client: subject, course_id: "a-valid-course-url")
        import_status = subject.get_course_import(id: import.result.id)

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
        import_status = subject.get_course_import(id: import.result.id)

        aggregate_failures do
          expect(import_status.success?).to eq true
          expect(import_status.result.error?).to eq true
          expect(import_status.result.course).to eq nil
        end
      end
    end
  end
end
