#
# TODO: Consider consolidating this and [Courses|Registrations]::Configuration, but only
#       after we're sure they are really 99.9% the same in terms of functionality.
#
module ScormEngine
  module Api
    module Endpoints
      module Tenants
        module Configuration

          #
          # Returns the effective value of every setting at this level, as well
          # as the effective value of any setting at a more specific level.
          #
          # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__configuration_get
          #
          # @return [ScormEngine::Models::TenantConfiguration]
          #
          def get_tenant_configuration
            response = get("configuration")

            result = response.success? ? ScormEngine::Models::TenantConfiguration.new_from_api(response.body) : nil

            Response.new(raw_response: response, result: result)
          end

          #
          # Bulk set configuration settings via POST request.
          #
          # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__configuration_post
          #
          # @param [Hash] options
          #
          # @option options [Hash] :settings
          #   Key/value pairs of configuration options to set.
          #
          # @return [ScormEngine::Response]
          #
          def post_tenant_configuration(options = {})
            require_options(options, :settings)

            options = options.dup
            settings = options.delete(:settings)

            body = { settings: settings.map { |k, v| { "settingId" => k, "value" => v.to_s } } }

            response = post("configuration", options, body)

            Response.new(raw_response: response)
          end

          #
          # Returns the effective value for this configuration setting for the resource being configured.
          #
          # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__configuration__settingId__get
          #
          # @param [Hash] options
          #
          # @option options [String] :setting_id
          #   The ID of the setting to get.
          #
          # @return [String]
          #
          def get_tenant_configuration_setting(options = {})
            require_options(options, :setting_id)

            options = options.dup
            setting_id = options.delete(:setting_id)

            response = get("configuration/#{setting_id}", options)

            result = response.success? ? response.body["value"] : nil

            Response.new(raw_response: response, result: result)
          end

          #
          # Sets the value for this configuration setting, for the resource being configured.
          #
          # @see https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__configuration__settingId__put
          #
          # @param [Hash] options
          #
          # @option options [String] :setting_id
          #   The ID of the setting to set.
          #
          # @option options [String] :value ("")
          #   The value of the setting to set.
          #
          # @return [ScormEngine::Response]
          #
          def put_tenant_configuration_setting(options = {})
            require_options(options, :setting_id)

            options = options.dup
            setting_id = options.delete(:setting_id)

            body = { value: options.delete(:value).to_s }

            response = put("configuration/#{setting_id}", options, body)

            Response.new(raw_response: response)
          end
        end
      end
    end
  end
end
