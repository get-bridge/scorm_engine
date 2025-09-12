# frozen_string_literal: true

RSpec.describe ScormEngine::Models::CourseImport do
  describe ".new_from_api" do
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

  describe "#error?" do
    subject(:course_import) { described_class.new_from_api(payload) }

    context "when status is ERROR" do
      let(:payload) { { "status" => "ERROR" } }

      it { is_expected.to be_error }
    end

    context "when status is not ERROR" do
      let(:payload) { { "status" => "OOPS" } }

      it { is_expected.not_to be_error }
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
