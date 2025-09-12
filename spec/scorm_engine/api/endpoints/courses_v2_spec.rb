require "spec_helper"
require_relative "../../../../support/scorm_engine_configuration"

RSpec.describe "ScormEngine::Api::Endpoints::Courses API v2 Integration" do
  let(:mock_client) do
    Class.new do
      include ScormEngine::Api::Endpoints::Courses

      attr_reader :api_version, :mock_responses

      def initialize(api_version)
        @api_version = api_version
        @mock_responses = {}
      end

      def current_api_version
        @api_version
      end

      def get(__path, __options = {})
        response_data = @mock_responses[path] || default_response
        MockResponse.new(response_data)
      end

      def set_mock_response(path, data)
        @mock_responses[path] = data
      end

      private

      def default_response
        { success: true, body: {} }
      end
    end
  end

  class MockResponse
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
  end

  describe "#get_courses with API v2" do
    let(:client) { mock_client.new(2) }

    context "when requesting a single course" do
      let(:single_course_data) do
        {
          success: true,
          body: {
            "id" => "course-123",
            "title" => "Test Course",
            "description" => "A test course for API v2"
          }
        }
      end

      it "returns course data directly for single course requests" do
        client.set_mock_response("courses/course-123", single_course_data)

        response = client.get_courses(course_id: "course-123")

        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true

        # Should yield the course directly, not wrapped in an array
        courses = response.result.to_a
        expect(courses).to have(1).item
        expect(courses.first).to be_a(ScormEngine::Models::Course)
        expect(courses.first.id).to eq("course-123")
        expect(courses.first.title).to eq("Test Course")
      end
    end

    context "when requesting multiple courses" do
      let(:multiple_courses_data) do
        {
          success: true,
          body: {
            "courses" => [
              {
                "id" => "course-1",
                "title" => "Course One",
                "description" => "First course"
              },
              {
                "id" => "course-2",
                "title" => "Course Two",
                "description" => "Second course"
              }
            ],
            "more" => nil
          }
        }
      end

      it "returns array of courses from courses endpoint" do
        client.set_mock_response("courses", multiple_courses_data)

        response = client.get_courses

        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true

        courses = response.result.to_a
        expect(courses).to have(2).items
        expect(courses.map(&:id)).to eq(%w[course-1 course-2])
        expect(courses.map(&:title)).to eq(["Course One", "Course Two"])
      end
    end

    context "with pagination" do
      let(:first_page_data) do
        {
          success: true,
          body: {
            "courses" => [
              { "id" => "course-1", "title" => "Course One" }
            ],
            "more" => "/courses?page=2"
          }
        }
      end

      let(:second_page_data) do
        {
          success: true,
          body: {
            "courses" => [
              { "id" => "course-2", "title" => "Course Two" }
            ],
            "more" => nil
          }
        }
      end

      it "handles pagination correctly" do
        client.set_mock_response("courses", first_page_data)
        client.set_mock_response("/courses?page=2", second_page_data)

        # Mock the get method to handle pagination paths
        allow(client).to receive(:get) do |path, _options|
          case path
          when "courses"
            MockResponse.new(first_page_data)
          when "/courses?page=2"
            MockResponse.new(second_page_data)
          else
            MockResponse.new(success: false, body: {})
          end
        end

        response = client.get_courses

        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be true

        # Should enumerate through all pages
        courses = response.result.to_a
        expect(courses).to have(2).items
        expect(courses.map(&:id)).to eq(%w[course-1 course-2])
      end
    end

    context "error handling" do
      let(:error_response) do
        {
          success: false,
          status: 404,
          body: { "message" => "Course not found" }
        }
      end

      it "handles course not found gracefully" do
        client.set_mock_response("courses/nonexistent", error_response)

        response = client.get_courses(course_id: "nonexistent")

        expect(response).to be_a(ScormEngine::Response)
        expect(response.success?).to be false
        expect(response.status).to eq(404)

        # Should return empty enumerator for failed requests
        courses = response.result.to_a
        expect(courses).to be_empty
      end

      it "handles malformed response data" do
        malformed_data = {
          success: true,
          body: "not a hash"
        }

        client.set_mock_response("courses/malformed", malformed_data)

        response = client.get_courses(course_id: "malformed")

        # Should not raise an exception, but return empty results
        expect { response.result.to_a }.not_to raise_error
        courses = response.result.to_a
        expect(courses).to be_empty
      end
    end
  end

  describe "backward compatibility with API v1" do
    let(:client) { mock_client.new(1) }

    it "maintains existing behavior for API v1 clients" do
      legacy_data = {
        success: true,
        body: {
          "courses" => [
            { "id" => "legacy-course", "title" => "Legacy Course" }
          ],
          "more" => nil
        }
      }

      client.set_mock_response("courses", legacy_data)

      response = client.get_courses

      expect(response).to be_a(ScormEngine::Response)
      courses = response.result.to_a
      expect(courses).to have(1).item
      expect(courses.first.id).to eq("legacy-course")
    end
  end
end
