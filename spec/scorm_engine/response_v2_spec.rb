require "spec_helper"

RSpec.describe ScormEngine::Response do
  subject(:response) { described_class.new(raw_response: mock_raw_response, result: mock_result) }

  let(:mock_result) { { "data" => "test" } }
  let(:mock_raw_response) do
    instance_double("RawResponse",
                    success?: true,
                    status: 200,
                    body: { "message" => "Success" },
                    headers: { "Content-Type" => "application/json" })
  end

  describe "#initialize" do
    it "sets raw_response and result" do
      expect(response).to have_attributes(raw_response: mock_raw_response, result: mock_result)
    end
  end

  describe "#success?" do
    it "delegates to raw_response true" do
      expect(response.success?).to be true
    end

    it "delegates to raw_response false" do
      allow(mock_raw_response).to receive(:success?).and_return(false)
      expect(response.success?).to be false
    end
  end

  describe "#status" do
    it "delegates to raw_response 200" do
      expect(response.status).to eq(200)
    end

    it "delegates to raw_response 404" do
      allow(mock_raw_response).to receive(:status).and_return(404)
      expect(response.status).to eq(404)
    end
  end

  describe "#body" do
    it "returns raw_response body" do
      expect(response.body).to eq({ "message" => "Success" })
    end
  end

  describe "#message" do
    context "when body is a hash with message key" do
      it "returns the message from body" do
        expect(response.message).to eq("Success")
      end
    end

    context "when body is not a hash" do
      let(:mock_raw_response) do
        instance_double("RawResponse",
                        success?: true,
                        status: 200,
                        body: "plain text response",
                        headers: {})
      end

      it "returns nil" do
        expect(response.message).to be_nil
      end
    end

    context "when body has no message key" do
      let(:mock_raw_response) do
        instance_double("RawResponse",
                        success?: true,
                        status: 200,
                        body: { "data" => "no message" },
                        headers: {})
      end

      it "returns nil" do
        expect(response.message).to be_nil
      end
    end
  end

  describe "#results" do
    context "when result is an Enumerator" do
      let(:enumerator) { [1, 2, 3].to_enum }
      let(:mock_result) { enumerator }

      it "returns the enumerator as is" do
        expect(response.results).to eq(enumerator)
      end
    end

    context "when result is not an Enumerator" do
      it "wraps result in an array" do
        expect(response.results).to eq([mock_result])
      end
    end

    context "when result is nil" do
      let(:mock_result) { nil }

      it "returns [nil]" do
        expect(response.results).to eq([nil])
      end
    end

    context "when result is already an array" do
      let(:mock_result) { [1, 2, 3] }

      it "wraps the array (returns [[1, 2, 3]])" do
        expect(response.results).to eq([[1, 2, 3]])
      end
    end
  end

  describe "#detailed_error_info" do
    context "when response is successful" do
      it "returns 'Success'" do
        expect(response.detailed_error_info).to eq("Success")
      end
    end

    context "when response is not successful" do
      let(:mock_raw_response) do
        instance_double("RawResponse",
                        success?: false,
                        status: 400,
                        body: { "message" => "Bad Request", "details" => "Invalid parameters" },
                        headers: { "Content-Type" => "application/json", "X-Error-Code" => "VALIDATION" })
      end

      it "returns detailed error information" do
        error_info = response.detailed_error_info

        expect(error_info).to include("status: 400",
                                      "message: \"Bad Request\"",
                                      "body: {\"message\"=>\"Bad Request\", \"details\"=>\"Invalid parameters\"}",
                                      "headers: {\"Content-Type\"=>\"application/json\", \"X-Error-Code\"=>\"VALIDATION\"}")
      end
    end

    context "when headers conversion fails" do
      let(:mock_headers) { instance_double("Headers") }
      let(:mock_raw_response) do
        instance_double("RawResponse",
                        success?: false,
                        status: 500,
                        body: { "message" => "Server Error" },
                        headers: mock_headers)
      end

      before do
        allow(mock_headers).to receive(:to_hash).and_raise(NoMethodError)
      end

      it "handles headers conversion gracefully" do
        expect { response.detailed_error_info }.not_to raise_error
      end
    end
  end

  describe "integration with real HTTP responses" do
    context "when simulating Faraday response behavior" do
      let(:faraday_response) do
        # Simulate a Faraday::Response-like object
        instance_double("FaradayResponse",
                        success?: false,
                        status: 404,
                        body: { "error" => "Course not found", "code" => "COURSE_NOT_FOUND" },
                        headers: { "content-type" => "application/json" })
      end

      let(:response) { described_class.new(raw_response: faraday_response) }

      it "provides comprehensive error details for debugging" do
        error_info = response.detailed_error_info

        expect(error_info).to be_a(String)
                          .and include("404", "Course not found", "COURSE_NOT_FOUND", "application/json")
      end
    end
  end
end
