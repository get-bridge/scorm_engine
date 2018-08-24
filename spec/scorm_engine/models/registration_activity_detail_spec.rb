RSpec.describe ScormEngine::Models::RegistrationActivityDetail do
  describe ".new_from_api" do
    let(:options) { {
      "id" => "activity-123",
      "runtime" => {
        "runtimeInteractions" => [
          { "id" => "root-interaction-1" },
          { "id" => "root-interaction-2" },
        ],
      },
      "children" => [
        {
          "id" => "child-1",
          "runtime" => {
            "runtimeInteractions" => [
              { "id" => "child-1-interaction-1" },
              { "id" => "child-1-interaction-2" },
            ],
          },
          "children" => [
            {
              "id" => "grandchild-1",
              "runtime" => { "runtimeInteractions" => [] },
            },
          ],
        },
        {
          "id" => "child-2",
          "runtime" => {
            "runtimeInteractions" => [
              { "id" => "child-2-interaction-1" },
            ],
          },
          "children" => [
            {
              "id" => "grandchild-2",
              "runtime" => {
                "runtimeInteractions" => [
                  { "id" => "grandchild-1-interaction-1" },
                  { "id" => "grandchild-1-interaction-2" },
                ],
              },
            },
            {
              "id" => "grandchild-3",
              "runtime" => {},
            },
          ],
        },
      ],
    } }

    let(:activity) { described_class.new_from_api(options) }

    describe ":id" do
      it "is set properly" do
        expect(activity.id).to eq "activity-123"
      end
    end

    describe ":children" do
      it "is set properly" do
        ids = activity.children.map(&:id)
        expect(ids).to match_array %w[child-1 child-2]
      end

      it "is set properly for children" do
        ids = activity.children.flat_map(&:children).map(&:id)
        expect(ids).to match_array %w[grandchild-1 grandchild-2 grandchild-3]
      end
    end

    describe ":runtime_interactions" do
      it "is set properly" do
        ids = activity.runtime_interactions.map(&:id)
        expect(ids).to match_array %w[root-interaction-1 root-interaction-2]
      end

      it "is set properly for children" do
        ids = activity.children.detect { |c| c.id == "child-1" }.runtime_interactions.map(&:id)
        expect(ids).to match_array %w[child-1-interaction-1 child-1-interaction-2]
      end

      it "is set properly for grandchildren" do
        child = activity.children.detect { |c| c.id == "child-2" }
        ids = child.children.detect { |c| c.id == "grandchild-2" }.runtime_interactions.map(&:id)
        expect(ids).to match_array %w[grandchild-1-interaction-1 grandchild-1-interaction-2]
      end
    end

    describe "#all_runtime_interactions" do
      it "returns all interactions" do
        expect(activity.all_runtime_interactions.map(&:id)).to match_array %w[
          root-interaction-1 root-interaction-2
          child-1-interaction-1 child-1-interaction-2 child-2-interaction-1
          grandchild-1-interaction-1 grandchild-1-interaction-2
        ]
      end
    end

    describe "#complete?" do
      it "is nil when completion is UNKNOWN" do
        activity = described_class.new_from_api("activityCompletion" => "UNKNOWN")
        expect(activity.complete?).to eq nil
      end

      it "is false when completion is INCOMPLETE" do
        activity = described_class.new_from_api("activityCompletion" => "INCOMPLETE")
        expect(activity.complete?).to eq false
      end

      it "is true when completion is COMPLETED" do
        activity = described_class.new_from_api("activityCompletion" => "COMPLETED")
        expect(activity.complete?).to eq true
      end
    end

    describe "#incomplete?" do
      it "is nil when completion is UNKNOWN" do
        activity = described_class.new_from_api("activityCompletion" => "UNKNOWN")
        expect(activity.incomplete?).to eq nil
      end

      it "is true when completion is INCOMPLETE" do
        activity = described_class.new_from_api("activityCompletion" => "INCOMPLETE")
        expect(activity.incomplete?).to eq true
      end

      it "is false when completion is COMPLETED" do
        activity = described_class.new_from_api("activityCompletion" => "COMPLETED")
        expect(activity.incomplete?).to eq false
      end
    end

    describe "#previous_attempt_complete?" do
      it "is nil when completion is Unknown" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Unknown")
        expect(activity.previous_attempt_complete?).to eq nil
      end

      it "is false when completion is Incomplete" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Incomplete")
        expect(activity.previous_attempt_complete?).to eq false
      end

      it "is true when completion is Completed" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Completed")
        expect(activity.previous_attempt_complete?).to eq true
      end
    end

    describe "#previous_atempt_incomplete?" do
      it "is nil when completion is Unknown" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Unknown")
        expect(activity.previous_attempt_incomplete?).to eq nil
      end

      it "is true when completion is Incomplete" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Incomplete")
        expect(activity.previous_attempt_incomplete?).to eq true
      end

      it "is false when completion is Completed" do
        activity = described_class.new_from_api("previousAttemptCompletion" => "Completed")
        expect(activity.previous_attempt_incomplete?).to eq false
      end
    end

    describe "#passed?" do
      it "is nil when completion is UNKNOWN" do
        activity = described_class.new_from_api("activitySuccess" => "UNKNOWN")
        expect(activity.passed?).to eq nil
      end

      it "is false when completion is FAILED" do
        activity = described_class.new_from_api("activitySuccess" => "FAILED")
        expect(activity.passed?).to eq false
      end

      it "is true when completion is PASSED" do
        activity = described_class.new_from_api("activitySuccess" => "PASSED")
        expect(activity.passed?).to eq true
      end
    end

    describe "#failed?" do
      it "is nil when completion is UNKNOWN" do
        activity = described_class.new_from_api("activitySuccess" => "UNKNOWN")
        expect(activity.failed?).to eq nil
      end

      it "is true when completion is FAILED" do
        activity = described_class.new_from_api("activitySuccess" => "FAILED")
        expect(activity.failed?).to eq true
      end

      it "is false when completion is PASSED" do
        activity = described_class.new_from_api("activitySuccess" => "PASSED")
        expect(activity.failed?).to eq false
      end
    end
  end
end
