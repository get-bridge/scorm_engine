RSpec.describe ScormEngine::Api::Endpoints::Courses do
  describe "#courses" do
    let(:subject) { ScormEngine::Client.new(tenant: "ScormEngineGemTesting").courses }

    it "is successful" do
      expect(subject.success?).to eq true
    end

    describe "results" do
      it "is an array of Course models" do
        expect(subject.results).to be_a Array
        expect(subject.results.first).to be_a ScormEngine::Models::Course
      end

      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = subject.results.first
          expect(course.id).to eq "course_1524151356"
          expect(course.version).to eq 0
          expect(course.title).to eq "LMS365"
          expect(course.registration_count).to eq 1
          expect(course.updated).to eq Time.parse("2018-04-19T15:22:43.000Z")
          expect(course.description).to eq "Introduction to LMS365"
        end
      end
    end

    describe ":since option" do
      it "works" do
        subject = ScormEngine::Client.new(tenant: "ScormEngineGemTesting").courses(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(subject.success?).to eq true
          expect(subject.results.size).to be >= 1
        end
      end

      it "fails when passed an invalid value" do
        subject = ScormEngine::Client.new(tenant: "ScormEngineGemTesting").courses(since: "invalid")
        aggregate_failures do
          expect(subject.success?).to eq false
          expect(subject.status).to eq 400
          expect(subject.results).to eq []
          expect(subject.message).to match /'invalid' is either not a timestamp or seems to be not formatted according to ISO 8601/
        end
      end
    end

    describe ":more option" do
      pending "Can't test until we have enough results to paginate. I think?"
    end
  end

  describe "#course_import" do
    pending
  end

  describe "#course_import_status" do
    pending
  end
end
