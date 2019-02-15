RSpec.describe ScormEngine::Models::DispatchRegistrationCount do
  describe ".new_from_api" do
    describe ":id" do
      it "is set" do
        dispatch = described_class.new_from_api(
          "id" => "dispatch-id"
        )
        expect(dispatch.id).to eq "dispatch-id"
      end
    end

    describe ":registration_count" do
      it "is set" do
        dispatch = described_class.new_from_api(
          "registrationCount" => "456"
        )
        expect(dispatch.registration_count).to eq 456
      end

      it "is set to zero when not an integer" do
        dispatch = described_class.new_from_api(
          "registrationCount" => "oops"
        )
        expect(dispatch.registration_count).to eq 0
      end
    end

    describe ":last_reset_at" do
      it "is set" do
        dispatch = described_class.new_from_api(
          "lastResetTime" => "2018-05-24T08:09:10Z"
        )
        expect(dispatch.last_reset_at).to eq Time.new(2018, 5, 24, 8, 9, 10, 0)
      end

      it "is set to nil if blank" do
        dispatch = described_class.new_from_api({})
        expect(dispatch.last_reset_at).to eq nil
      end
    end
  end
end
