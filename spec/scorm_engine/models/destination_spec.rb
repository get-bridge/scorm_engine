RSpec.describe ScormEngine::Models::Destination do
  describe ".new_from_api" do
    describe ":name" do
      it "is set when passed at the root level" do
        course = described_class.new_from_api(
          "name" => "test"
        )
        expect(course.name).to eq "test"
      end

      it "is set when passed at within `data`" do
        course = described_class.new_from_api(
          "data" => {
            "name" => "test"
          }
        )
        expect(course.name).to eq "test"
      end
    end
  end
end
