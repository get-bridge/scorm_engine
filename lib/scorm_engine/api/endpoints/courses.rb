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
        # @return [Enumerator<ScormEngine::Models::Course>] in the result
        #
        def courses(options = {})
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
        # @returns [ScormEngine::Response]
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
        # @returns [ScormEngine::Response]
        #
        def course_detail(options = {})
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
        # @returns [ScormEngine::Response]
        #
        def course_preview(options = {})
          course_id = options.delete(:course_id)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          options[:redirectOnExitUrl] = options.delete(:redirect_on_exit_url)
          response = get("courses/#{course_id}/preview", options)
          result = if response.success?
                     response.body["launchLink"]
                   end
          Response.new(raw_response: response, result: result)
        end

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
        def set_course_configuration(options = {})
          course_id = options.delete(:course_id)
          settings = options.delete(:settings)
          raise ArgumentError.new('Required arguments :course_id missing') if course_id.nil?
          raise ArgumentError.new('Required arguments :settings missing') if settings.nil?
          body = {settings: settings.map { |k, v| { "settingId" => k, "value" => v.to_s } }}
          response = post("courses/#{course_id}/configuration", options, body)
          Response.new(raw_response: response)
        end

        #
        # Import a course
        #
        # Either the actual contents of the zip file to import may be posted,
        # or JSON that references the remote location to import from.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses_importJobs_post
        #
        # @param [Hash] options
        #
        # @option options [String] :url
        #   URL path to the .zip package representing the course or the manifest file defining the course.
        #
        # @option options [String] :course_id
        #   A unique identifier your application will use to identify the
        #   course after import. Your application is responsible both for
        #   generating this unique ID and for keeping track of the ID for later
        #   use.
        #
        # @option options [Boolean] :may_create_new_version (false)
        #   Is it OK to create a new version of this course? If this is set to
        #   false and the course already exists, the upload will fail. If true
        #   and the course already exists then a new version will be created.
        #   No effect if the course doesn't already exist.
        #
        # @option options [String] :name (value of :course)
        #   A unique identifier that may be used as part of the directory name on disk.
        #
        # @return [ScormEngine::Models::CourseImport] in the result
        #
        def course_import(options = {})
          raise ArgumentError.new('Required arguments :course_id missing') if options[:course_id].nil?
          raise ArgumentError.new('Required arguments :url missing') if options[:url].nil?

          query_params = {
            course: options[:course_id],
            mayCreateNewVersion: !!options[:may_create_new_version]
          }

          body = {
            url: options[:url],
            courseName: options[:name] || options[:course_id],
          }

          response = post("courses/importJobs", query_params, body)

          result = if response&.success?
                     ScormEngine::Models::CourseImport.new_from_api(response.body)
                   end

          Response.new(raw_response: response, result: result)
        end

        #
        # This method will check the status of a course import.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses_importJobs__importJobId__get
        #
        # @param [Hash] options
        #
        # @option options [String] :id
        #   The id of the import to check.
        #
        # @return [ScormEngine::Models::CourseImport] in the result
        #
        def course_import_status(options = {})
          raise ArgumentError.new('Required arguments :id missing') if options[:id].nil?

          response = get("courses/importJobs/#{options[:id]}")

          result = if response&.success?
                     # jobId is not always returned. :why:
                     ScormEngine::Models::CourseImport.new_from_api({"jobId" => options[:id]}.merge(response.body))
                   end

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
