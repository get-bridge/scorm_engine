#
# TODO: Consider consolidating this and [Registrations|Tenants]::Configuration, but only
#       after we're sure they are really 99.9% the same in terms of functionality.
#
module ScormEngine
  module Api
    module Endpoints
      module Courses
        module Configuration

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
          # @return [ScormEngine::Models::CourseConfiguration]
          #
          def get_course_configuration(options = {})
            require_options(options, :course_id)

            options = options.dup
            course_id = options.delete(:course_id)

            response = get("courses/#{course_id}/configuration", options)

            result = response.success? ? ScormEngine::Models::CourseConfiguration.new_from_api(response.body) : nil

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
          #   The ID of the course to set.
          #
          # @option options [Integer] :version (nil)
          #   The version of this course to use. If not provided, the latest
          #   version will be used.
          #
          # @option options [Hash] :settings
          #   Key/value pairs of configuration options to set.
          #
          # @return [ScormEngine::Response]
          #
          def post_course_configuration(options = {})
            require_options(options, :course_id, :settings)

            options = options.dup
            course_id = options.delete(:course_id)
            settings = options.delete(:settings)

            body = { settings: settings.map { |k, v| { "settingId" => k, "value" => v.to_s } } }

            response = post("courses/#{course_id}/configuration", options, body)

            Response.new(raw_response: response)
          end

          #
          # Returns the effective value for this configuration setting for the resource being configured.
          #
          # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__configuration__settingId__get
          #
          # @param [Hash] options
          #
          # @option options [String] :course_id
          #   The ID of the course to get.
          #
          # @option options [String] :setting_id
          #   The ID of the setting to get.
          #
          # @option options [Integer] :version (nil)
          #   The version of this course to use. If not provided, the latest
          #   version will be used.
          #
          # @return [String]
          #
          def get_course_configuration_setting(options = {})
            require_options(options, :course_id, :setting_id)

            options = options.dup
            course_id = options.delete(:course_id)
            setting_id = options.delete(:setting_id)

            response = get("courses/#{course_id}/configuration/#{setting_id}", options)

            result = response.success? ? response.body["value"] : nil

            Response.new(raw_response: response, result: result)
          end

          #
          # Sets the value for this configuration setting, for the resource being configured.
          #
          # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses__courseId__configuration__settingId__put
          #
          # @param [Hash] options
          #
          # @option options [String] :course_id
          #   The ID of the course to set.
          #
          # @option options [String] :setting_id
          #   The ID of the setting to set.
          #
          # @option options [String] :value ("")
          #   The value of the setting to set.
          #
          # @option options [Integer] :version (nil)
          #   The version of this course to use. If not provided, the latest
          #   version will be used.
          #
          # @return [ScormEngine::Response]
          #
          def put_course_configuration_setting(options = {})
            require_options(options, :course_id, :setting_id)

            options = options.dup
            course_id = options.delete(:course_id)
            setting_id = options.delete(:setting_id)

            body = { value: options.delete(:value).to_s }

            response = put("courses/#{course_id}/configuration/#{setting_id}", options, body)

            Response.new(raw_response: response)
          end
        end
      end
    end
  end
end
