require "spec_helper"
require_relative "../../../support/scorm_engine_configuration"

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

      it "correctly parses API v2 import response with nested data" do
        import = described_class.new_from_api(api_v2_import_response)
        
        expect(import.id).to eq("job-123")
        expect(import.status).to eq("RUNNING")
        expect(import.parser_warnings).to eq(["Warning 1", "Warning 2"])
        expect(import.course).to be_a(ScormEngine::Models::Course)
        expect(import.course.id).to eq("course-123")
        expect(import.course.title).to eq("Test Course")
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
        
        expect(import.id).to eq("job-456")
        expect(import.status).to eq("RUNNING")
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

      it "correctly parses API v1 format for backward compatibility" do
        import = described_class.new_from_api(api_v1_response)
        
        expect(import.id).to eq("job-789")
        expect(import.status).to eq("COMPLETED")
        expect(import.parser_warnings).to eq(["Legacy warning"])
        expect(import.course).to be_a(ScormEngine::Models::Course)
        expect(import.course.id).to eq("course-789")
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
        
        expect(import.id).to eq("job-error")
        expect(import.status).to eq("ERROR")
        expect(import.parser_warnings).to eq(["Fatal error occurred"])
        expect(import.course).to be_nil
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
end
