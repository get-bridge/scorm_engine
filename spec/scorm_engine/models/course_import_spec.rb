require "spec_helper"

RSpec.describe ScormEngine::Models::CourseImport do
  describe "#new_from_api" do
    context "with API v2 response format" do
      let(:api_v2_import_response) do
        {
          "jobId" => "job-123",
          "status" => "RUNNING",
          "importResult" => {
            "parserWarnings" => ["Warning 1", "Warning 2"],
            "course" => {
              "id" => "course-123",
              "title" => "Test Course",
              "description" => "A test course"
            }
          }
        }
      end

      it "correctly parses API v2 import response with nested data attributes" do
        import = described_class.new_from_api(api_v2_import_response)

        expect(import).to have_attributes(id: "job-123", status: "RUNNING", parser_warnings: ["Warning 1", "Warning 2"])
      end

      it "correctly parses API v2 import response with nested data type" do
        import = described_class.new_from_api(api_v2_import_response)

        expect(import.course).to be_a(ScormEngine::Models::Course)
          .and have_attributes(id: "course-123", title: "Test Course")
      end

      it "handles completed import status" do
        completed_response = api_v2_import_response.merge("status" => "COMPLETED")

        import = described_class.new_from_api(completed_response)

        expect(import.status).to eq("COMPLETED")
      end

      it "handles failed import status" do
        failed_response = api_v2_import_response.merge("status" => "ERROR")

        import = described_class.new_from_api(failed_response)

        expect(import.status).to eq("ERROR")
      end
    end

    context "with initial import response (result only)" do
      let(:initial_response) do
        {
          "result" => "job-456"
        }
      end

      it "creates import with running status for initial response" do
        import = described_class.new_from_api(initial_response)

        expect(import).to have_attributes(id: "job-456", status: "RUNNING")
      end
    end

    context "with API v1 compatibility format" do
      let(:api_v1_response) do
        {
          "jobId" => "job-789",
          "status" => "COMPLETED",
          "course" => {
            "id" => "course-789",
            "title" => "Legacy Course"
          },
          "parserWarnings" => ["Legacy warning"]
        }
      end

      it "correctly parses API v1 format for backward compatibility attributes" do
        import = described_class.new_from_api(api_v1_response)

        expect(import).to have_attributes(id: "job-789", status: "COMPLETED", parser_warnings: ["Legacy warning"])
      end

      it "correctly parses API v1 format for backward compatibility type" do
        import = described_class.new_from_api(api_v1_response)

        expect(import.course).to be_a(ScormEngine::Models::Course)
          .and have_attributes(id: "course-789")
      end
    end

    context "with error states" do
      let(:error_response) do
        {
          "jobId" => "job-error",
          "status" => "ERROR",
          "importResult" => {
            "parserWarnings" => ["Fatal error occurred"]
          }
        }
      end

      it "handles error states without course data" do
        import = described_class.new_from_api(error_response)

        expect(import).to have_attributes(id: "job-error", status: "ERROR", parser_warnings: ["Fatal error occurred"], course: nil)
      end
    end

    describe "status validation" do
      it "uppercases status values consistently" do
        response = { "jobId" => "test", "status" => "running" }
        import = described_class.new_from_api(response)

        expect(import.status).to eq("RUNNING")
      end

      it "handles nil status gracefully" do
        response = { "jobId" => "test", "status" => nil }
        import = described_class.new_from_api(response)

        expect(import.status).to be_nil
      end
    end
  end

  describe "#completed?" do
    it "returns true for COMPLETED status" do
      import = described_class.new_from_api({ "jobId" => "test", "status" => "COMPLETED" })
      expect(import.completed?).to be true
    end

    it "returns false for RUNNING status" do
      import = described_class.new_from_api({ "jobId" => "test", "status" => "RUNNING" })
      expect(import.completed?).to be false
    end

    it "returns false for ERROR status" do
      import = described_class.new_from_api({ "jobId" => "test", "status" => "ERROR" })
      expect(import.completed?).to be false
    end
  end

  describe "#error?" do
    it "returns true for ERROR status" do
      import = described_class.new_from_api({ "jobId" => "test", "status" => "ERROR" })
      expect(import.error?).to be true
    end

    it "returns false for COMPLETED status" do
      import = described_class.new_from_api({ "jobId" => "test", "status" => "COMPLETED" })
      expect(import.error?).to be false
    end
  end

  # Legacy tests for basic .new_from_api functionality
  describe ".new_from_api (legacy tests)" do
    context "when :importResult is present" do
      subject(:course_import) do
        described_class.new_from_api(
          "result" => "id123",
          "importResult" => { "status" => "running", "parserWarnings" => "watch out" }
        )
      end

      it "sets the id" do
        expect(course_import.id).to eq "id123"
      end

      it "sets the status" do
        expect(course_import.status).to eq "RUNNING"
      end

      it "sets the course to nil" do
        expect(course_import.course).to be_nil
      end

      it "sets the parser_warnings" do
        expect(course_import.parser_warnings).to eq "watch out"
      end
    end

    context "when :importResult is present but parserWarnings are absent" do
      subject(:course_import) { described_class.new_from_api("importResult" => {}) }

      it "sets the parser_warnings to nil" do
        expect(course_import.parser_warnings).to be_nil
      end
    end

    context "when :importResult is absent" do
      subject(:course_import) do
        described_class.new_from_api(
          "jobId" => "id123",
          "status" => "COMPLETE",
          "course" => { "id" => "course123" }
        )
      end

      it "sets the id" do
        expect(course_import.id).to eq "id123"
      end

      it "sets the status" do
        expect(course_import.status).to eq "COMPLETE"
      end

      it "sets the course if present" do
        expect(course_import.course)
          .to be_a(ScormEngine::Models::Course)
          .and have_attributes(id: "course123")
      end
    end

    context "when :importResult is absent and course is missing" do
      subject(:course_import) { described_class.new_from_api({}) }

      it "sets the course to nil" do
        expect(course_import.course).to be_nil
      end
    end
  end

  describe "#running?" do
    subject(:course_import) { described_class.new_from_api(payload) }

    context "when status is RUNNING" do
      let(:payload) { { "status" => "RUNNING" } }

      it { is_expected.to be_running }
    end

    context "when status is not RUNNING" do
      let(:payload) { { "status" => "OOPS" } }

      it { is_expected.not_to be_running }
    end
  end

  describe "#complete?" do
    subject(:course_import) { described_class.new_from_api(payload) }

    context "when status is COMPLETE" do
      let(:payload) { { "status" => "COMPLETE" } }

      it { is_expected.to be_complete }
    end

    context "when status is not COMPLETE" do
      let(:payload) { { "status" => "OOPS" } }

      it { is_expected.not_to be_complete }
    end
  end
end
