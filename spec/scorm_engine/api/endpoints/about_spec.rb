RSpec.describe ScormEngine::Api::Endpoints::About do
  describe "#about" do
    let(:subject) { ScormEngine::Client.new(tenant: "ScormEngineGemTesting").about }

    it "is successful" do
      expect(subject.success?).to eq true
    end

    it "knows the version" do
      expect(subject.result.version).to eq "2017.1.28.969"
    end

    it "knows the platform" do
      expect(subject.result.platform).to eq "Java"
    end
  end

  describe "#about_user_count" do
    let(:subject) { ScormEngine::Client.new(tenant: "ScormEngineGemTesting").about_user_count }

    it "is successful" do
      expect(subject.success?).to eq true
    end

    it "tracks combined counts" do
      aggregate_failures do
        expect(subject.result.total).to be >= 1
        expect(subject.result.dispatched).to be >= 0
        expect(subject.result.non_dispatched).to be >= 0
      end
    end

    it "tracks per tenantcounts" do
      aggregate_failures do
        expect(subject.result.by_tenant).to be_a Hash
        tenant = subject.result.by_tenant.first.last
        expect(tenant.total).to be >= 0
        expect(tenant.dispatched).to be >= 0
        expect(tenant.non_dispatched).to be >= 0
      end
    end

    it "accepts :before option" do
      subject = ScormEngine::Client.new(tenant: "ScormEngineGemTesting").about_user_count(before: Time.parse("1901-01-1").utc)
      aggregate_failures do
        expect(subject.success?).to eq true
        expect(subject.result.total).to eq 0
      end
    end

    it "accepts :since option" do
      subject = ScormEngine::Client.new(tenant: "ScormEngineGemTesting").about_user_count(since: Time.parse("2031-01-1").utc)
      aggregate_failures do
        expect(subject.success?).to eq true
        expect(subject.result.total).to eq 0
      end
    end
  end
end
