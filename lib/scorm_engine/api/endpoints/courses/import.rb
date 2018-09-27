module ScormEngine
  module Api
    module Endpoints
      module Courses
        module Import

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
          # @option options [String] :course_id
          #   A unique identifier your application will use to identify the
          #   course after import. Your application is responsible both for
          #   generating this unique ID and for keeping track of the ID for later
          #   use.
          #
          # @option options [String] :url
          #   URL path to the .zip package representing the course or the
          #   manifest file defining the course. Mutually exclusive with
          #   :pathname.
          #
          # @option options [String] :pathname
          #   Local file path to the .zip package representing the course.
          #   Mutually exclusive with :url.
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
          # @return [ScormEngine::Models::CourseImport]
          #
          def post_course_import(options = {})
            require_options(options, :course_id)
            require_exclusive_option(options, :url, :pathname)

            query_params = {
              course: options[:course_id],
              mayCreateNewVersion: !!options[:may_create_new_version]
            }

            body = if options[:url]
                     { url: options[:url], courseName: options[:name] || options[:course_id] }
                   elsif options[:pathname]
                     { file: ::Faraday::UploadIO.new(options[:pathname], "application/zip") }
                   end

            response = post("courses/importJobs", query_params, body)

            result = response&.success? ? ScormEngine::Models::CourseImport.new_from_api(response.body) : nil

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
          # @return [ScormEngine::Models::CourseImport]
          #
          def get_course_import(options = {})
            require_options(options, :id)

            response = get("courses/importJobs/#{options[:id]}")

            # jobId is not always returned. :why:
            result = response&.success? ? ScormEngine::Models::CourseImport.new_from_api({ "jobId" => options[:id] }.merge(response.body)) : nil

            Response.new(raw_response: response, result: result)
          end
        end
      end
    end
  end
end
