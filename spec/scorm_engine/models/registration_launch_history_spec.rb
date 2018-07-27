RSpec.describe ScormEngine::Models::RegistrationLaunchHistory do
  describe ".new_from_api" do
    let(:launch_history) { described_class.new_from_api(
      "id" => "registration-456",
      "instanceId" => 1.0,
      "launchTime" => "07/25/2018 20:02:02 PM",
      "launchTimeUtc" => "07/25/2018 20:02:02 PM",
      "exitTime" => "07/25/2018 20:02:14 PM",
      "exitTimeUtc" => "07/25/2018 20:02:14 PM",
      "completionStatus" => "Incomplete",
      "successStatus" => "Failed",
      "lastRuntimeUpdate" => "07/25/2018 20:02:14 PM",
      "lastRuntimeUpdateUtc" => "2018-07-25T20:01:58.000Z", # intentionally tweaked from what is really returned
      "score" => { "scaled" => 93.0 },
    )}

    describe ":id" do
      it "is set properly" do
        expect(launch_history.id).to eq "registration-456"
      end
    end

    describe ":score" do
      it "is set properly" do
        expect(launch_history.score).to eq 93.0
      end

      it "is left unset if not present" do
        launch_history = described_class.new_from_api({})
        expect(launch_history.score).to eq nil
      end
    end

    describe ":total_seconds_tracked" do
      it "is set properly when set in the root level with a trailing space" do
        launch_history = described_class.new_from_api("totalSecondsTracked " => 123)
        expect(launch_history.total_seconds_tracked).to eq 123
      end

      it "is set properly when set in the root level without a trailing space" do
        launch_history = described_class.new_from_api("totalSecondsTracked" => 123)
        expect(launch_history.total_seconds_tracked).to eq 123
      end

      it "is set properly when set in the score object with a trailing space" do
        launch_history = described_class.new_from_api("score" => { "totalSecondsTracked " => 123 })
        expect(launch_history.total_seconds_tracked).to eq 123
      end

      it "is set properly when set in the score object without a trailing space" do
        launch_history = described_class.new_from_api("score" => { "totalSecondsTracked" => 123 })
        expect(launch_history.total_seconds_tracked).to eq 123
      end

      it "is set to zero when it's negative" do
        launch_history = described_class.new_from_api("totalSecondsTracked" => -9.223372036854776e+16)
        expect(launch_history.total_seconds_tracked).to eq 0
      end

      it "is left unset if not present" do
        launch_history = described_class.new_from_api({})
        expect(launch_history.total_seconds_tracked).to eq nil
      end
    end

    describe ":instance_id" do
      it "is coerced to an integer" do
        expect(launch_history.instance_id).to eq 1
      end
    end

    %i[launch_time exit_time last_runtime_update].each do |attr|
      describe ":#{attr}" do
        it "is set properly in the UTC timezone" do
          expect(launch_history.send(attr)).to be_a Time
          expect(launch_history.send(attr).zone).to eq "UTC"
        end

        it "is left unset if not present" do
          launch_history = described_class.new_from_api({})
          expect(launch_history.send(attr)).to eq nil
        end
      end
    end
  end
end
