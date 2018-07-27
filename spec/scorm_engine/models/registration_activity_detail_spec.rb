RSpec.describe ScormEngine::Models::RegistrationActivityDetail do
  describe ".new_from_api" do
    let(:options) {{
      "id" => "activity-123",
      "runtime" => {
        "runtimeInteractions" => [
          {"id" => "root-interaction-1"},
          {"id" => "root-interaction-2"},
        ]
      },
      "children" => [
        {
          "id" => "child-1",
          "runtime" => {
            "runtimeInteractions" => [
              {"id" => "child-1-interaction-1"},
              {"id" => "child-1-interaction-2"},
            ]
          },
          "children" => [
            {
              "id" => "grandchild-1",
              "runtime" => {"runtimeInteractions" => []},
            },
          ],
        },
        {
          "id" => "child-2",
          "runtime" => {
            "runtimeInteractions" => [
              {"id" => "child-2-interaction-1"},
            ]
          },
          "children" => [
            {
              "id" => "grandchild-2",
              "runtime" => {
                "runtimeInteractions" => [
                  {"id" => "grandchild-1-interaction-1"},
                  {"id" => "grandchild-1-interaction-2"},
                ]
              },
            },
            {
              "id" => "grandchild-3",
              "runtime" => {},
            },
          ],
        },
      ],
    }}

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
        ids = activity.children.detect {|c| c.id == "child-1"}.runtime_interactions.map(&:id)
        expect(ids).to match_array %w[child-1-interaction-1 child-1-interaction-2]
      end

      it "is set properly for grandchildren" do
        child = activity.children.detect {|c| c.id == "child-2"}
        ids = child.children.detect {|c| c.id == "grandchild-2"}.runtime_interactions.map(&:id)
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
  end
end
