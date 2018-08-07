RSpec.describe ScormEngine::Models::RegistrationRuntimeInteraction do
  describe ".new_from_api" do
    let(:options) { {
      "id" => "interaction-123",
      "description" => "  foo \t bar \n baz  ",
      "timestampUtc" => "2018-05-24T00:01:02.00Z",
      "correctResponses" => %w[one two],
      "learnerResponse" => "one",
      "result" => "correct",
      "weighting" => "3",
      "latency" => "0012:34:59"
    } }

    let(:interaction) { described_class.new_from_api(options) }

    describe ":id" do
      it "is set properly" do
        expect(interaction.id).to eq "interaction-123"
      end
    end

    describe ":description" do
      it "is set properly" do
        expect(interaction.description).to eq "foo bar baz"
      end

      it "is set to nil if blank" do
        interaction = described_class.new_from_api(options.merge("description" => " "))
        expect(interaction.description).to eq nil
      end

      it "is set to nil if literal value 'null'" do
        interaction = described_class.new_from_api(options.merge("description" => "null"))
        expect(interaction.description).to eq nil
      end
    end

    describe ":timestamp" do
      it "is set properly" do
        expect(interaction.timestamp.iso8601).to eq "2018-05-24T00:01:02Z"
      end

      it "is set to nil if blank" do
        interaction = described_class.new_from_api(options.merge("timestampUtc" => ""))
        expect(interaction.timestamp).to eq nil
      end
    end

    describe ":correct_responses" do
      it "is set properly" do
        expect(interaction.correct_responses).to eq %w[one two]
      end
    end

    describe ":learner_response" do
      it "is set properly" do
        expect(interaction.learner_response).to eq "one"
      end
    end

    describe ":result" do
      it "is set properly" do
        expect(interaction.result).to eq "correct"
      end
    end

    describe ":weighting" do
      it "is set properly" do
        expect(interaction.weighting).to eq "3"
      end
    end

    describe ":latency" do
      it "is set properly" do
        expect(interaction.latency).to eq "0012:34:59"
      end
    end

    describe "#latency_in_seconds" do
      it "parses valid values" do
        interaction = described_class.new_from_api("latency" => "0012:34:59")
        expect(interaction.latency_in_seconds).to eq 45_299
      end

      it "returns zero for invalid values" do
        interaction = described_class.new_from_api("latency" => "wat")
        expect(interaction.latency_in_seconds).to eq 0
      end
    end
  end
end
