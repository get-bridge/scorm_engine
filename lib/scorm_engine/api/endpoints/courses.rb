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
        # @option options [String] :id 
        #   The ID of the single course to retrieve. If set no other options
        #   are respected.
        #
        # @option options [DateTime] :since 
        #   Only courses updated since the specified ISO 8601 TimeStamp
        #   (inclusive) are included.  If a time zone is not specified, the
        #   server's time zone will be used.
        #
        # @return [Array<ScormEngine::Models::Course>] in the result
        #
        def courses(options = {})
          response = if options[:id]
                       get("courses/#{options[:id]}")
                     else
                       get("courses", options)
                     end

          result = if response.success?
                     response.body["courses"].map do |course|
                       ScormEngine::Models::Course.new_from_api(course)
                     end
                   else
                     []
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
        # @option options [String] :id 
        #   The ID of the course to delete.
        #
        # @returns [ScormEngine::Response]
        #
        def delete_course(options = {})
          raise ArgumentError.new('Required arguments :id missing') if options[:id].nil?
          response = delete("courses/#{options[:id]}")
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
        # @option options [String] :course
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
          raise ArgumentError.new('Required arguments :course missing') if options[:course].nil?
          raise ArgumentError.new('Required arguments :url missing') if options[:url].nil?
          options[:name] ||= options[:course]

          query_params = {
            course: options[:course],
            mayCreateNewVersion: !!options[:may_create_new_version]
          }

          body = {
            url: options[:url],
            courseName: options[:name] || options[:course],
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
                     ScormEngine::Models::CourseImport.new_from_api(response.body)
                   end

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
