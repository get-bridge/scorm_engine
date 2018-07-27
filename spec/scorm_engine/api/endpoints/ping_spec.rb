RSpec.describe ScormEngine::Api::Endpoints::Ping do
  describe "#get_ping" do
    let(:subject) { scorm_engine_client.get_ping }

    it "is successful" do
      expect(subject.success?).to eq true
    end

    it "reports the api is up" do
      expect(subject.message).to match(/API is up/)
    end

    context "with invalid password" do
      before do
        ScormEngine.configuration.password = "invalid"
      end

      it "is unsuccessful" do
        expect(subject.success?).to eq false
      end

      it "returns status 403" do
        expect(subject.status).to eq 403
      end
    end
  end
end
