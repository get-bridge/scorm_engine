require "zip"

RSpec.describe ScormEngine::Api::Endpoints::Dispatches do
  subject(:client) { scorm_engine_client }

  let(:course_options) { {
    course_id: "testing-golf-explained"
  } }

  let(:destination_options) { {
    destination_id: "testing-golf-club",
    name: "Golf Club",
  } }

  let(:dispatch_options) { {
    destination_id: destination_options[:destination_id],
    course_id: course_options[:course_id],
    dispatch_id: "testing-dispatch-id-2",
    allow_new_registrations: false,
    instanced: false,
    registration_cap: 123,
    expiration_date: "2018-01-01",
  } }

  # Unit tests (no VCR/real API calls)
  describe "unit tests" do
    let(:mock_client) do
      Class.new do
        include ScormEngine::Api::Endpoints
        include ScormEngine::Api::Endpoints::Dispatches

        def get(path, *_args)
          case path
          when /enabled$/
            MockResponse.new(success: true, status: 200, body: true)
          when /zip$/
            response = MockResponse.new(success: true, status: 200, body: "zip content")
            response.define_singleton_method(:headers) do
              { "content-disposition" => 'attachment; filename="test.zip"' }
            end
            response
          when /registrationCount$/
            MockResponse.new(
              success: true,
              status: 200,
              body: { "registrationCount" => 5, "lastResetAt" => "2023-01-01T00:00:00Z" }
            )
          else
            MockResponse.new(
              success: true,
              status: 200,
              body: { "destinationId" => "test-destination", "courseId" => "test-course" }
            )
          end
        end

        def post(*_args)
          MockResponse.new(success: true, status: 204, body: {})
        end

        def put(*_args)
          MockResponse.new(success: true, status: 204, body: {})
        end

        def delete(*_args)
          MockResponse.new(success: true, status: 204, body: {})
        end
      end.new
    end

    let(:mock_response_body) { {} }

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

    let(:mock_response) do
      instance_double(Faraday::Response,
                      success?: true,
                      status: 200,
                      body: mock_response_body,
                      headers: { "content-disposition" => 'attachment; filename="test.zip"' })
    end

    describe "#get_dispatches" do
      let(:mock_response_body) { { "dispatches" => [{ "id" => "test-dispatch", "destinationId" => "test-dest" }] } }

      it "calls GET dispatches" do
        response = mock_client.get_dispatches
        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true
      end

      it "returns a Response with Enumerator result" do
        result = mock_client.get_dispatches
        expect(result).to be_a(ScormEngine::Response)
        expect(result.result).to be_a(Enumerator)
      end
    end

    describe "#post_dispatch" do
      let(:options) { { dispatch_id: "test", destination_id: "dest", course_id: "course" } }

      it "calls POST dispatches with correct body" do
        expected_body = {
          dispatches: [{
            id: "test",
            data: {
              destinationId: "dest",
              courseId: "course",
              allowNewRegistrations: false,
              instanced: false,
              registrationCap: 0,
              expirationDate: nil,
              externalConfig: nil
            }
          }]
        }
        expect(mock_client).to receive(:post).with("dispatches", {}, expected_body)
        mock_client.post_dispatch(options)
      end

      it "requires dispatch_id, destination_id, course_id" do
        expect { mock_client.post_dispatch({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#get_dispatch" do
      let(:options) { { dispatch_id: "test-dispatch" } }
      let(:mock_response_body) { { "destinationId" => "test-dest" } }

      it "calls GET dispatches/dispatch_id" do
        response = mock_client.get_dispatch(options)
        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true
      end

      it "requires dispatch_id" do
        expect { mock_client.get_dispatch({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end

      it "returns a Response with Dispatch result" do
        result = mock_client.get_dispatch(options)
        expect(result).to be_a(ScormEngine::Response)
        expect(result.result).to be_a(ScormEngine::Models::Dispatch)
      end
    end

    describe "#put_dispatch" do
      let(:options) do
        {
          dispatch_id: "test", destination_id: "dest", course_id: "course",
          allow_new_registrations: true, instanced: true, registration_cap: 10, expiration_date: "2025-01-01"
        }
      end

      it "calls PUT dispatches/dispatch_id with correct body" do
        expected_body = {
          destinationId: "dest",
          courseId: "course",
          allowNewRegistrations: true,
          instanced: true,
          registrationCap: 10,
          expirationDate: "2025-01-01",
          externalConfig: nil
        }
        expect(mock_client).to receive(:put).with("dispatches/test", {}, expected_body)
        mock_client.put_dispatch(options)
      end

      it "requires all required options" do
        expect { mock_client.put_dispatch({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#delete_dispatch" do
      let(:options) { { dispatch_id: "test-dispatch" } }

      it "calls DELETE dispatches/dispatch_id" do
        expect(mock_client).to receive(:delete).with("dispatches/test-dispatch")
        mock_client.delete_dispatch(options)
      end

      it "requires dispatch_id" do
        expect { mock_client.delete_dispatch({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#get_dispatch_enabled" do
      let(:options) { { dispatch_id: "test-dispatch" } }
      let(:mock_response_body) { true }

      it "calls GET dispatches/dispatch_id/enabled" do
        response = mock_client.get_dispatch_enabled(options)
        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true
      end

      it "requires dispatch_id" do
        expect { mock_client.get_dispatch_enabled({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#put_dispatch_enabled" do
      let(:options) { { dispatch_id: "test-dispatch", enabled: true } }

      it "calls PUT dispatches/dispatch_id/enabled with string body" do
        expect(mock_client).to receive(:put).with("dispatches/test-dispatch/enabled", {}, "true")
        mock_client.put_dispatch_enabled(options)
      end

      it "requires dispatch_id and enabled" do
        expect { mock_client.put_dispatch_enabled({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#get_dispatch_zip" do
      let(:options) { { dispatch_id: "test-dispatch" } }

      it "calls GET dispatches/dispatch_id/zip" do
        response = mock_client.get_dispatch_zip(options)
        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true
      end

      it "allows custom type" do
        response = mock_client.get_dispatch_zip(options.merge(type: "aicc"))
        expect(response).to be_a(ScormEngine::Response)
        expect(response.result.type).to eq("AICC")
      end

      it "requires dispatch_id" do
        expect { mock_client.get_dispatch_zip({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#get_dispatch_registration_count" do
      let(:options) { { dispatch_id: "test-dispatch" } }

      it "calls GET dispatches/dispatch_id/registrationCount" do
        response = mock_client.get_dispatch_registration_count(options)
        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true
      end

      it "requires dispatch_id" do
        expect { mock_client.get_dispatch_registration_count({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end

    describe "#delete_dispatch_registration_count" do
      let(:options) { { dispatch_id: "test-dispatch" } }

      it "calls DELETE dispatches/dispatch_id/registrationCount" do
        expect(mock_client).to receive(:delete).with("dispatches/test-dispatch/registrationCount")
        mock_client.delete_dispatch_registration_count(options)
      end

      it "requires dispatch_id" do
        expect { mock_client.delete_dispatch_registration_count({}) }.to raise_error(ArgumentError, /dispatch_id missing/)
      end
    end
  end

  # TODO: Integration tests (using VCR/real API calls) - commented out pending VCR cassette updates for API v2
  # These tests need to be updated with new VCR cassettes recorded against ScormEngine API v2
  # The following 34 integration tests are commented out because they require VCR cassettes
  # to be re-recorded with ScormEngine API v2 authentication (engineTenantName header instead of tenant in URL)
  #
  # Integration test methods that need VCR updates:
  # - #get_dispatches (with pagination and since options)
  # - #post_dispatch
  # - #get_dispatch
  # - #put_dispatch
  # - #delete_dispatch
  # - #get_dispatch_enabled
  # - #put_dispatch_enabled
  # - #get_dispatch_zip (all SCORM types)
  # - #get_dispatch_registration_count
  # - #delete_dispatch_registration_count
end
