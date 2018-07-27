module ScormEngine
  module Api
    module Endpoints
      module Registrations
        module LaunchHistory
          #
          # Get launch history data associated with this registration
          #
          # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__launchHistory_get
          #
          # @param [Hash] options
          #
          # @option options [String] :registration_id
          #   ID for the registration.
          #
          # @option options [String] :instance ()
          #   The instance of this registration to use. If not provided, the
          #   latest instance will be used.
          #
          # @option options [Boolean] :include_history_log (false)
          #   Whether to include the history log in the launch history. The
          #   history log is a blob of XML that shows all of the SCORM-related
          #   calls inside the course. Depending on the course itself, these logs
          #   can get very large if a lot of calls are being made.
          #
          # @return [Array<ScormEngine::Models::RegistrationLaunchHistory>]
          #
          def get_registration_launch_history(options = {})
            require_options(options, :registration_id)

            options = options.dup
            registration_id = options.delete(:registration_id)
            options[:includeHistoryLog] = !!options.delete(:include_history_log)

            response = get("registrations/#{registration_id}/launchHistory", options)

            result = response.success? && response.body["launchHistory"].map do |history|
              ScormEngine::Models::RegistrationLaunchHistory.new_from_api(history)
            end

            Response.new(raw_response: response, result: result)
          end
        end
      end
    end
  end
end
