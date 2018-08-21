RSpec.describe ScormEngine::Models::DispatchZip do
  describe ".new" do
    it "set the attributes correctly" do
      dispatch_zip = described_class.new(
        dispatch_id: 123,
        type: "SCORM12",
        filename: "dispatch.zip",
        body: "raw zip string",
      )
      aggregate_failures do
        expect(dispatch_zip.dispatch_id).to eq 123
        expect(dispatch_zip.type).to eq "SCORM12"
        expect(dispatch_zip.filename).to eq "dispatch.zip"
        expect(dispatch_zip.body).to eq "raw zip string"
      end
    end
  end
end
