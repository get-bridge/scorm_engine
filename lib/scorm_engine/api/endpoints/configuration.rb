module ScormEngine
  module Api
    module Endpoints
      module Configuration
        #
        # Get the application settings currently configured in Engine.
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/20.1.x/api/apiV2.html#/appManagement/GetApplicationConfiguration
        #
        # @param [Hash] options
        #
        # @option options [Boolean] :for_tenant
        #   Indicates whether the configuration effective for the current tenant should be fetched.
        #   If false or not specified, will return configuration settings for the application in general.
        #
        # @return [ScormEngine::Response]
        #
        def get_app_configuration(options = {})
          api_v2(without_tenant: !options.fetch(:for_tenant, false)) do
            options.delete(:for_tenant)

            response = get("appManagement/configuration", options)

            result = OpenStruct.new

            response.body["settingItems"].each do |setting|
              result[setting["id"]] = setting["effectiveValue"]
            end

            Response.new(raw_response: response, result: result)
          end
        end

        #
        # Set one or more application settings in Engine.
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/20.1.x/api/apiV2.html#/appManagement/SetApplicationConfiguration
        #
        # @param [Hash] options
        #
        # @option [Hash] settings
        #   The configuration settings to be updated.
        #
        # @option options [Boolean] :for_tenant
        #   Indicates whether the configuration should be set for the current tenant.
        #   If false or not specified, will update configuration settings for the application in general.
        #
        # @return [ScormEngine::Response]
        #
        def post_app_configuration(options = {})
          require_options(options, :settings)

          api_v2(without_tenant: !options.fetch(:for_tenant, false)) do
            settings = options.delete(:settings)

            body = { settings: settings.map { |k, v| { "settingId" => k, "value" => v.to_s } } }

            response = post("appManagement/configuration", {}, body)

            Response.new(raw_response: response)
          end
        end

        #
        # Deletes the current value for a setting, reverting it to its default value.
        #
        # @see https://rustici-docs.s3.amazonaws.com/engine/20.1.x/api/apiV2.html#/appManagement/DeleteApplicationConfigurationSetting
        #
        # @param [Hash] options
        #
        # @option [String] setting_id
        #   The ID for the setting to be deleted.
        #
        # @option options [Boolean] :for_tenant
        #   Indicates whether the configuration should be set for the current tenant.
        #   If false or not specified, will update configuration settings for the application in general.
        #
        # @return [ScormEngine::Response]
        #
        def delete_app_configuration(options = {})
          require_options(options, :setting_id)

          api_v2(without_tenant: !options.fetch(:for_tenant, false)) do
            setting_id = options.delete(:setting_id)

            response = delete("appManagement/configuration/#{setting_id}")

            Response.new(raw_response: response)
          end
        end
      end
    end
  end
end
