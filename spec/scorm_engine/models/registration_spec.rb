RSpec.describe ScormEngine::Models::Registration do
  describe ".new_from_api" do
    let(:options) { {
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
    } }

    let(:registration) { described_class.new_from_api(options) }

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

    describe ":completed_date" do
      it "is set properly when key is in root level" do
        registration = described_class.new_from_api(options.merge("completedDate" => "2018-05-24T00:01:02.000Z"))
        expect(registration.completed_date).to be_a Time
        expect(registration.completed_date.iso8601).to eq "2018-05-24T00:01:02Z"
      end

      it "is set properly when key is in score object" do
        registration = described_class.new_from_api(options.merge("score" => { "completedDate" => "2018-05-24T00:01:02.000Z" }))
        expect(registration.completed_date).to be_a Time
        expect(registration.completed_date.iso8601).to eq "2018-05-24T00:01:02Z"
      end

      it "is left unset if not present" do
        expect(registration.completed_date).to eq nil
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

    describe "#complete?" do
      it "is nil when completion is UNKNOWN" do
        registration = described_class.new_from_api("registrationCompletion" => "UNKNOWN")
        expect(registration.complete?).to eq nil
      end

      it "is false when completion is INCOMPLETE" do
        registration = described_class.new_from_api("registrationCompletion" => "INCOMPLETE")
        expect(registration.complete?).to eq false
      end

      it "is true when completion is COMPLETED" do
        registration = described_class.new_from_api("registrationCompletion" => "COMPLETED")
        expect(registration.complete?).to eq true
      end
    end

    describe "#incomplete??" do
      it "is nil when completion is UNKNOWN" do
        registration = described_class.new_from_api("registrationCompletion" => "UNKNOWN")
        expect(registration.incomplete?).to eq nil
      end

      it "is true when completion is INCOMPLETE" do
        registration = described_class.new_from_api("registrationCompletion" => "INCOMPLETE")
        expect(registration.incomplete?).to eq true
      end

      it "is false when completion is COMPLETED" do
        registration = described_class.new_from_api("registrationCompletion" => "COMPLETED")
        expect(registration.incomplete?).to eq false
      end
    end

    describe "#passed?" do
      it "is nil when completion is Unknown" do
        registration = described_class.new_from_api("registrationSuccess" => "Unknown")
        expect(registration.passed?).to eq nil
      end

      it "is false when completion is Failed" do
        registration = described_class.new_from_api("registrationSuccess" => "Failed")
        expect(registration.passed?).to eq false
      end

      it "is true when completion is Passed" do
        registration = described_class.new_from_api("registrationSuccess" => "Passed")
        expect(registration.passed?).to eq true
      end
    end

    describe "#failed?" do
      it "is nil when completion is Unknown" do
        registration = described_class.new_from_api("registrationSuccess" => "Unknown")
        expect(registration.failed?).to eq nil
      end

      it "is true when completion is Failed" do
        registration = described_class.new_from_api("registrationSuccess" => "Failed")
        expect(registration.failed?).to eq true
      end

      it "is false when completion is Passed" do
        registration = described_class.new_from_api("registrationSuccess" => "Passed")
        expect(registration.failed?).to eq false
      end
    end
  end
end
