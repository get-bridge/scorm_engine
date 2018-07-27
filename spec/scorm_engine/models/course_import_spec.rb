RSpec.describe ScormEngine::Models::CourseImport do
  describe ".new_from_api" do
    describe "when :importResult is present" do
      let(:subject) { described_class.new_from_api("result" => "id123", "importResult" => { "status" => "RUNNING", "parserWarnings" => "watch out" }) }

      it "sets the id" do
        expect(subject.id).to eq "id123"
      end

      it "sets the status" do
        expect(subject.status).to eq "RUNNING"
      end

      it "sets the course to nil" do
        expect(subject.course).to eq nil
      end

      it "sets the parser_warnings" do
        expect(subject.parser_warnings).to eq "watch out"
      end

      it "sets the parser_warnings to nil if not present" do
        subject = described_class.new_from_api("importResult" => {})
        expect(subject.parser_warnings).to eq nil
      end
    end

    describe "when :importResult is absent" do
      let(:subject) { described_class.new_from_api("jobId" => "id123", "status" => "COMPLETE", "course" => { "id" => "course123" }) }

      it "sets the id" do
        expect(subject.id).to eq "id123"
      end

      it "sets the status" do
        expect(subject.status).to eq "COMPLETE"
      end

      it "sets the course if present" do
        expect(subject.course).to be_a ScormEngine::Models::Course
        expect(subject.course.id).to eq "course123"
      end

      it "sets the course to nil if absent" do
        subject = described_class.new_from_api({})
        expect(subject.course).to eq nil
      end
    end
  end

  describe "#running?" do
    it "is true when status is RUNNING" do
      subject = described_class.new_from_api("status" => "RUNNING")
      expect(subject.running?).to eq true
    end

    it "is false when status is not RUNNING" do
      subject = described_class.new_from_api("status" => "OOPS")
      expect(subject.running?).to eq false
    end
  end

  describe "#error?" do
    it "is true when status is ERROR" do
      subject = described_class.new_from_api("status" => "ERROR")
      expect(subject.error?).to eq true
    end

    it "is false when status is not ERROR" do
      subject = described_class.new_from_api("status" => "OOPS")
      expect(subject.error?).to eq false
    end
  end

  describe "#complete?" do
    it "is true when status is COMPLETE" do
      subject = described_class.new_from_api("status" => "COMPLETE")
      expect(subject.complete?).to eq true
    end

    it "is false when status is not COMPLETTE" do
      subject = described_class.new_from_api("status" => "OOPS")
      expect(subject.complete?).to eq false
    end
  end
end
