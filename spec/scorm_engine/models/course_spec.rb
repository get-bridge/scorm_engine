RSpec.describe ScormEngine::Models::Course do
  describe ".new_from_api" do
    describe ":title" do
      it "is blank when title is blank" do
        course = described_class.new_from_api(
          "id" => "test"
        )
        expect(course.title).to eq ""
      end

      it "is blank when title is blank" do
        course = described_class.new_from_api(
          "id" => "test", "title" => ""
        )
        expect(course.title).to eq ""
      end

      it "is blank when title is literally 'Title'" do
        course = described_class.new_from_api(
          "id" => "test", "title" => "Title"
        )
        expect(course.title).to eq ""
      end

      it "is blank when title is literally 'Captivate E-Learning Course'" do
        course = described_class.new_from_api(
          "id" => "test", "title" => "Captivate E-Learning Course"
        )
        expect(course.title).to eq ""
      end

      it "is correct when title contains escaped HTML" do
        course = described_class.new_from_api(
          "id" => "test", "title" => "&lt;b&gt;The &lt;a href=&quot;foo&quot;&gt;Title&lt;/a&gt;&lt;/b&gt;"
        )
        expect(course.title).to eq "The Title"
      end

      it "is correct when title contains unescaped HTML" do
        course = described_class.new_from_api(
          "id" => "test", "title" => "<b>The <a href='foo'>Title</a></b>"
        )
        expect(course.title).to eq "The Title"
      end

      it "is correct when title contains lots of white space" do
        course = described_class.new_from_api(
          "id" => "test", "title" => " The  \n\tTitle "
        )
        expect(course.title).to eq "The Title"
      end
    end

    describe ":scaled_passing_score" do
      it "is nil when rootActivity is blank" do
        course = described_class.new_from_api(
          "id" => "test"
        )
        expect(course.scaled_passing_score).to eq nil
      end

      it "is nil when rootActivity/children is blank" do
        course = described_class.new_from_api(
          "id" => "test", "rootActivity" => {"children" => []}
        )
        expect(course.scaled_passing_score).to eq nil
      end

      it "is nil when rootActivity/children/scaledPassingScore is blank" do
        course = described_class.new_from_api(
          "id" => "test", "rootActivity" => {"children" => [{"scaledPassingScore" => nil}]}
        )
        expect(course.scaled_passing_score).to eq nil
      end

      {
        "0" => 0,
        "0.5" => 50,
        "1.0" => 100,
        "2" => 2,
        "100" => 100,
      }.each do |value, score|
        it "is #{score} when rootActivity/children/scaledPassingScore is '#{value}'" do
          course = described_class.new_from_api(
            "id" => "test", "rootActivity" => {"children" => [{"scaledPassingScore" => value}]}
          )
          expect(course.scaled_passing_score).to eq score
        end
      end
    end
  end
end
