RSpec.describe ScormEngine::Api::Endpoints::Ping do
  subject(:client) { scorm_engine_client }

  describe "#get_ping" do
    let(:client) { scorm_engine_client.get_ping }

    it "is successful" do
      expect(client.success?).to eq true
    end

    it "reports the api is up" do
      expect(client.message).to match(/API is up/)
    end

    context "with invalid password" do
      before do
        ScormEngine.configuration.password = "invalid"
      end

      it "is unsuccessful" do
        expect(client.success?).to eq false
      end

      it "returns status 403" do
        expect(client.status).to eq 403
      end
    end
  end
end
