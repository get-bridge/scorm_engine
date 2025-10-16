module ScormEngine
  module Api
    module Endpoints
      module Courses

        #
        # Get the list of courses
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses_get
        # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__get
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The ID of the single course to retrieve. If set no other options
        #   are respected. Note that multiple results may be returned if the
        #   course has multiple versions.
        #
        # @option options [DateTime] :since
        #   Only courses updated since the specified ISO 8601 TimeStamp
        #   (inclusive) are included.  If a time zone is not specified, the
        #   server's time zone will be used.
        #
        # @return [Enumerator<ScormEngine::Models::Course>]
        #
        def get_courses(options = {})
          options = options.dup

          path = "courses"
          single_course_id = options.delete(:course_id)
          path = "courses/#{single_course_id}" if single_course_id

          response = get(path, options)

          result = Enumerator.new do |enum|
            if single_course_id
              # Single course endpoint returns course data directly
              if response.success? && response.raw_response.body.is_a?(Hash) # rubocop:disable Style/IfUnlessModifier
                enum << ScormEngine::Models::Course.new_from_api(response.raw_response.body)
              end
            else
              # Multiple courses endpoint returns array in "courses" key
              loop do
                break unless response.success? && response.raw_response.body.is_a?(Hash)

                courses = response.raw_response.body["courses"]
                break unless courses.is_a?(Array)

                courses.each do |course|
                  enum << ScormEngine::Models::Course.new_from_api(course)
                end

                more_url = response.raw_response.body["more"]
                break if more_url.nil?

                response = get(more_url)
              end
            end
          end

          Response.new(raw_response: response, result: result)
        end

        #
        # Delete a course
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__delete
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The ID of the course to delete.
        #
        # @return [ScormEngine::Response]
        #
        def delete_course(options = {})
          require_options(options, :course_id)

          response = delete("courses/#{options[:course_id]}")

          Response.new(raw_response: response)
        end

        #
        # Get the details of a course
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__detail_get
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
        # @return [ScormEngine::Models::Course]
        #
        def get_course_detail(options = {})
          require_options(options, :course_id)

          options = options.dup
          course_id = options.delete(:course_id)

          response = get("courses/#{course_id}/detail", options)

          result = response.success? ? ScormEngine::Models::Course.new_from_api(response.raw_response.body) : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Returns the launch link to use to preview this course
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__preview_get
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
        # @option options [Integer] :expiry (0)
        #   Number of seconds from now this link will expire in. Use 0 for no
        #   expiration.
        #
        # @option options [String] :redirect_on_exit_url
        #   The URL the application should redirect to when the learner exits a
        #   course. If not specified, configured value will be used.
        #
        # @return [String]
        #
        def get_course_preview(options = {})
          require_options(options, :course_id)

          options = options.dup
          course_id = options.delete(:course_id)
          options[:redirectOnExitUrl] = options.delete(:redirect_on_exit_url) if options.key?(:redirect_on_exit_url)

          response = get("courses/#{course_id}/preview", options)

          result = response.success? ? response.raw_response.body["launchLink"] : nil

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
