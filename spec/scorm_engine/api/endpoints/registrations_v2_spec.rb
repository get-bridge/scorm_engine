require "spec_helper"
require_relative "../../../../support/scorm_engine_configuration"

RSpec.describe ScormEngine::Api::Endpoints::RegistrationsV2 do
  let(:mock_client) do
    Class.new do
      include ScormEngine::Api::Endpoints::Registrations

      attr_reader :api_version

      def initialize(api_version)
        @api_version = api_version
      end

      def current_api_version
        @api_version
      end

      def get(*_args)
        MockResponse.new
      end

      def post(*_args)
        MockResponse.new(
          success: true,
          status: 200,
          body: { "launchLink" => "https://example.com/launch?method=POST" }
        )
      end
    end
  end

  before do
    stub_const("MockResponse", Class.new do
      attr_reader :raw_response

      def initialize(data)
        @data = data
        @raw_response = self
      end

      def success?
        @data[:success] != false
      end

      def body
        @data[:body] || {}
      end

      def status
        @data[:status] || 200
      end
    end)
  end

  describe "#get_launch_link" do
    let(:registration_id) { "reg-123" }
    let(:launch_options) do
      {
        redirect_on_exit_url: "https://example.com/exit"
      }
    end

    context "with API v2" do
      let(:client) { mock_client.new(2) }

      it "uses POST method for launch links in API v2, to receive" do
        allow(client).to receive(:post)

        expect(client).to have_received(:post).with("registrations/#{registration_id}/launchLink", {}, { redirectOnExitUrl: "https://example.com/exit" }).and_call_original
      end

      it "uses POST method for launch links in API v2, scorm engine type" do
        response = client.get_launch_link(registration_id: registration_id, **launch_options)

        expect(response).to be_a(ScormEngine::Response)
      end

      it "uses POST method for launch links in API v2, result to equal" do
        response = client.get_launch_link(registration_id: registration_id, **launch_options)

        expect(response.result).to eq("https://example.com/launch?method=POST")
      end

      it "transforms redirect_on_exit_url parameter correctly" do
        allow(client).to receive(:post)

        expect(client).to have_received(:post).with("registrations/#{registration_id}/launchLink", {}, hash_including(redirectOnExitUrl: "https://example.com/exit"))

        client.get_launch_link(registration_id: registration_id, **launch_options)
      end

      it "handles additional launch parameters" do
        extended_options = launch_options.merge(theme: "dark", language: "en-US")
        allow(client).to receive(:post)

        expect(client).to have_received(:post).with("registrations/#{registration_id}/launchLink", {}, hash_including(redirectOnExitUrl: "https://example.com/exit", theme: "dark", language: "en-US"))

        client.get_launch_link(registration_id: registration_id, **extended_options)
      end
    end

    context "with API v1" do
      let(:client) { mock_client.new(1) }

      it "uses GET method for launch links in API v1 (backward compatibility), to receive" do
        allow(client).to receive(:post)

        expect(client).to have_received(:get).with("registrations/#{registration_id}/launchLink", { redirectOnExitUrl: "https://example.com/exit" }).and_call_original
      end

      it "uses GET method for launch links in API v1 (backward compatibility), scorm engine type" do
        response = client.get_launch_link(registration_id: registration_id, **launch_options)

        expect(response).to be_a(ScormEngine::Response)
      end

      it "uses GET method for launch links in API v1 (backward compatibility), result to equal" do
        response = client.get_launch_link(registration_id: registration_id, **launch_options)

        expect(response.result).to eq("https://example.com/launch?method=GET")
      end

      it "passes parameters as query parameters in API v1" do
        allow(client).to receive(:post)

        expect(client).to have_received(:get).with("registrations/#{registration_id}/launchLink", hash_including(redirectOnExitUrl: "https://example.com/exit"))

        client.get_launch_link(registration_id: registration_id, **launch_options)
      end
    end

    context "when error handling" do
      let(:client) { mock_client.new(2) }

      let(:error_response) do
        MockResponse.new(
          success: false,
          status: 404,
          body: { "message" => "Registration not found" }
        )
      end

      it "handles registration not found gracefully, scorm engine type" do
        allow(client).to receive(:post).and_return(error_response)

        response = client.get_launch_link(registration_id: "nonexistent")

        expect(response).to be_a(ScormEngine::Response)
      end

      it "handles registration not found gracefully, success false" do
        allow(client).to receive(:post).and_return(error_response)

        response = client.get_launch_link(registration_id: "nonexistent")

        expect(response.success?).to be false
      end

      it "handles registration not found gracefully, result nil" do
        allow(client).to receive(:post).and_return(error_response)

        response = client.get_launch_link(registration_id: "nonexistent")

        expect(response.result).to be_nil
      end
    end

    context "with parameter transformation" do
      let(:client) { mock_client.new(2) }

      it "correctly transforms camelCase parameters" do
        options = { redirect_on_exit_url: "https://example.com/exit", additional_params: "test=value" }

        allow(client).to receive(:post)

        expect(client).to have_received(:post).with(anything, anything, hash_including(redirectOnExitUrl: "https://example.com/exit", additional_params: "test=value"))

        client.get_launch_link(registration_id: registration_id, **options)
      end

      it "preserves original parameter names when no transformation is needed" do
        options = { theme: "custom", language: "fr-FR" }

        allow(client).to receive(:post)

        expect(client).to have_received(:post).with(anything, anything, hash_including(theme: "custom", language: "fr-FR"))
        client.get_launch_link(registration_id: registration_id, **options)
      end
    end

    describe "real-world usage patterns have, received" do
      let(:client) { mock_client.new(2) }

      it "handles typical LMS launch scenario" do
        allow(client).to receive(:post)

        expect(client).to have_received(:post).with("registrations/#{registration_id}/launchLink", hash_including(redirectOnExitUrl: "https://lms.example.com/course/complete", theme: "lms-branded", language: "en-US", show_progress: true))
      end

      it "handles typical LMS launch scenario, with all parameters" do
        lms_options = { redirect_on_exit_url: "https://lms.example.com/course/complete", theme: "lms-branded", language: "en-US", show_progress: true }

        response = client.get_launch_link(registration_id: registration_id, **lms_options)
        expect(response.result).to be_a(String)
      end

      it "handles typical LMS launch scenario, with https parameters" do
        lms_options = { redirect_on_exit_url: "https://lms.example.com/course/complete", theme: "lms-branded", language: "en-US", show_progress: true }

        response = client.get_launch_link(registration_id: registration_id, **lms_options)
        expect(response.result).to start_with("https://")
      end
    end
  end
end
