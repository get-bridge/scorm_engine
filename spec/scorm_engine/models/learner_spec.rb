RSpec.describe ScormEngine::Models::Learner do
  describe ".new_from_api" do
    let(:learner) { described_class.new_from_api(
      "id" => "learner-123",
      "firstName" => "Bobby",
      "lastName" => "Jones",
    ) }

    describe ":id" do
      it "is set properly" do
        expect(learner.id).to eq "learner-123"
      end
    end

    describe ":first_name" do
      it "is set properly" do
        expect(learner.first_name).to eq "Bobby"
      end
    end

    describe ":last_name" do
      it "is set properly" do
        expect(learner.last_name).to eq "Jones"
      end
    end
  end
end
