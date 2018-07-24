module ScormEngine
  module Api
    module Endpoints
      module Courses

        #
        # Get the list of courses
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses_get
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__get
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
          path = "courses"
          path = "courses/#{options.delete(:course_id)}" if options[:course_id]

          response = get(path, options)

          result = Enumerator.new do |enum|
            loop do
              response.success? && response.body["courses"].each do |course|
                enum << ScormEngine::Models::Course.new_from_api(course)
              end
              break if !response.success? || response.body["more"].nil?
              response = get(response.body["more"])
            end
          end

          Response.new(raw_response: response, result: result)
        end
        
        #
        # Delete a course
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__delete
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The ID of the course to delete.
        #
        # @return [ScormEngine::Response]
        #
        def delete_course(options = {})
          raise ArgumentError.new('Required arguments :course_id missing') if options[:course_id].nil?
          response = delete("courses/#{options[:course_id]}")
          Response.new(raw_response: response)
        end

        #
        # Get the details of a course
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__detail_get
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
          course_id = options.delete(:course_id)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          response = get("courses/#{course_id}/detail", options)
          result = if response.success?
                     ScormEngine::Models::Course.new_from_api(response.body)
                   end
          Response.new(raw_response: response, result: result)
        end

        #
        # Returns the launch link to use to preview this course
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__preview_get
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
          course_id = options.delete(:course_id)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          options[:redirectOnExitUrl] = options.delete(:redirect_on_exit_url)
          response = get("courses/#{course_id}/preview", options)
          result = if response.success?
                     response.body["launchLink"]
                   end
          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
