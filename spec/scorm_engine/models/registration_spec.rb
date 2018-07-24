RSpec.describe ScormEngine::Models::Registration do
  describe ".new_from_api" do
    let(:registration) { described_class.new_from_api(
      "id" => "registration-456",
      "score" => {
        "scaled" => "3.14159",
        "additionalProperties" => {},
      },
      "course" => {
        "id" => "course-789",
        "title" => "Golf 101",
      },
      "learner" => {
        "id" => "learner-123",
        "firstName" => "Bobby",
        "lastName" => "Jones",
      },
    )}

    describe ":id" do
      it "is set properly" do
        expect(registration.id).to eq "registration-456"
      end
    end

    describe ":score" do
      it "is set properly" do
        expect(registration.score).to be_a Numeric
        expect(registration.score.round(2)).to eq 3.14
      end

      it "is left unset if not present" do
        registration = described_class.new_from_api({})
        expect(registration.score).to eq nil
      end
    end

    describe ":course" do
      it "is set properly" do
        expect(registration.course).to be_a ScormEngine::Models::Course
        expect(registration.course.id).to eq "course-789"
      end

      it "is left unset if not present" do
        registration = described_class.new_from_api({})
        expect(registration.course).to eq nil
      end
    end

    describe ":learner" do
      it "is set properly" do
        expect(registration.learner).to be_a ScormEngine::Models::Learner
        expect(registration.learner.id).to eq "learner-123"
      end

      it "is left unset if not present" do
        registration = described_class.new_from_api({})
        expect(registration.learner).to eq nil
      end
    end

  end
end
