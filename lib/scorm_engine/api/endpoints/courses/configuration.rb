module ScormEngine
  module Api
    module Endpoints
      module Courses::Configuration

        #
        # Returns the effective value of every setting at this level, as well
        # as the effective value of any setting at a more specific level.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__configuration_get
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The ID of the course to get.
        #
        # @option options [Integer] :version (nil)
        #   The version of this course to use. If not provided, the latest
        #   version will be used.
        #
        # @returns [ScormEngine::Response]
        #
        def get_course_configuration(options = {})
          course_id = options.delete(:course_id)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          response = get("courses/#{course_id}/configuration", options)
          result = if response.success?
                     ScormEngine::Models::CourseConfiguration.new_from_api(response.body)
                   end
          Response.new(raw_response: response, result: result)
        end

        #
        # Bulk set configuration settings via POST request.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__configuration_post
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The ID of the course to get.
        #
        # @option options [Integer] :version (nil)
        #   The version of this course to use. If not provided, the latest
        #   version will be used.
        #
        # @option options [Hash] :settings
        #   Key/value pairs of configuration options to set.
        #
        # @returns [ScormEngine::Response]
        #
        def post_course_configuration(options = {})
          course_id = options.delete(:course_id)
          settings = options.delete(:settings)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          raise ArgumentError.new('Required arguments :settings missing') if settings.nil?
          body = {settings: settings.map { |k, v| { "settingId" => k, "value" => v.to_s } }}
          response = post("courses/#{course_id}/configuration", options, body)
          Response.new(raw_response: response)
        end
      end
    end
  end
end
