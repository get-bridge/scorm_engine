module ScormEngine
  module Api
    module Endpoints
      module Registrations

        #
        # Gets a list of registrations including a summary of the status of
        # each registration.
        #
        # @note Note the "since" parameter exists to allow
        #       retreiving only registrations that have changed, and the
        #       "before" parameter exists to allow retreiving only
        #       registrations that haven't changed.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations_get
        #
        # @param [Hash] options
        #
        # @option options [DateTime] :before ()
        #   Only registrations updated before the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @option options [DateTime] :since ()
        #   Only registrations updated since the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @option options [String] :course_id ()
        #   Only registrations for the specified course id will be included.
        #
        # @option options [String] :learner_id ()
        #   Only registrations for the specified learner id will be included.
        #
        # @return [Enumerator<ScormEngine::Models::Registration>]
        #
        def get_registrations(options = {})
          options = options.dup
          options[:courseId] = options.delete(:course_id) if options.key?(:course_id)
          options[:learnerId] = options.delete(:learner_id) if options.key?(:learner_id)

          response = get("registrations", options)

          result = Enumerator.new do |enum|
            loop do
              response.success? && response.body["registrations"].each do |registration|
                enum << ScormEngine::Models::Registration.new_from_api(registration)
              end
              break if !response.success? || response.body["more"].nil?
              response = get(response.body["more"])
            end
          end

          Response.new(raw_response: response, result: result)
        end

        #
        # Get all the instances of this the registration specified by the registration ID
        #
        # Multiple instances of a registration are created based on the value
        # you have for the setting "WhenToRestartRegistration". By default,
        # Engine will "restart" a registration once that registration is
        # completed and there is a newer version of that registration's package
        # is available. If both of those conditions are met when the
        # registration is launched, then Engine will create a new instance for
        # that registration.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__instances_get
        #
        # @param [Hash] options
        #
        # @option options [String] :registration_id
        #   ID for the registration.
        #
        # @option options [DateTime] :before ()
        #   Only registrations updated before the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @option options [DateTime] :since ()
        #   Only registrations updated since the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @return [Enumerator<ScormEngine::Models::Registration>]
        #
        def get_registration_instances(options = {})
          require_options(options, :registration_id)

          options = options.dup
          registration_id = options.delete(:registration_id)

          response = get("registrations/#{registration_id}/instances", options)

          result = Enumerator.new do |enum|
            loop do
              response.success? && response.body["registrations"].each do |registration|
                enum << ScormEngine::Models::Registration.new_from_api(registration)
              end
              break if !response.success? || response.body["more"].nil?
              response = get(response.body["more"])
            end
          end

          Response.new(raw_response: response, result: result)
        end

        #
        # Does this registration exist? You can also use the 'instance'
        # parameter to check if a particular instance of a registrations
        # exists.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__get
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
        # @return [ScormEngine::Response]
        #
        def get_registration_exists(options = {})
          require_options(options, :registration_id)

          options = options.dup
          registration_id = options.delete(:registration_id)

          response = get("registrations/#{registration_id}", options)

          result = response.success? ? response.body["exists"] : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Get registration summary
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__progress_get
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__progress_detail_get
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
        # @option options [Boolean] :detail (false)
        #   Whether or not to populate 'activityDetails'.
        #
        # @return [ScormEngine::Models::Registration]
        #
        def get_registration_progress(options = {})
          require_options(options, :registration_id)

          options = options.dup
          registration_id = options.delete(:registration_id)
          detail = !!options.delete(:detail)

          url = "registrations/#{registration_id}/progress"
          url += "/detail" if detail

          response = get(url, options)

          result = response.success? ? ScormEngine::Models::Registration.new_from_api(response.body) : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Delete a registration.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__delete
        #
        # @param [Hash] options
        #
        # @option options [String] :registration_id
        #   ID for the registration.
        #
        # @return [ScormEngine::Response]
        #
        def delete_registration(options = {})
          require_options(options, :registration_id)

          options = options.dup
          registration_id = options.delete(:registration_id)

          response = delete("registrations/#{registration_id}")

          Response.new(raw_response: response)
        end

        #
        # Create a registration.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations_post
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   The course ID.
        #
        # @option options [String] :registration_id
        #   The registration's ID. Must be unique.
        #
        # @option options [String] :learner/:id
        #   The learner's ID.
        #
        # @option options [String] :learner/:first_name
        #   The learner's first name.
        #
        # @option options [String] :learner/:last_name
        #   The learner's last name.
        #
        # @option options [String] :post_back/:url ()
        #   Specifies an optional override URL for which to post activity and
        #   status data in real time as the course is completed. By default all
        #   of these settings are read from your configuration, so only specify
        #   this if you need to control it on a per-registration basis.
        #
        # @option options [String] :post_back/:auth_type ("FORM")
        #   Optional parameter to specify how to authorize against the given
        #   postbackurl, can be 'FORM' or 'HTTPBASIC'. If form authentication,
        #   the username and password for authentication are submitted as form
        #   fields 'username' and 'password', and the registration data as the
        #   form field 'data'. If HTTP Basic Authentication is used, the
        #   username and password are placed in the standard Authorization HTTP
        #   header, and the registration data is the body of the message (sent
        #   as application/json content type).
        #
        # @option options [String] :post_back/:user_name ()
        #   The user name to be used in authorizing the postback of data to the
        #   URL specified by postback url.
        #
        # @option options [String] :post_back/:password ()
        #   The password to be used in authorizing the postback of data to the
        #   URL specified by postback url.
        #
        # @option options [String] :post_back/:results_format ("course")
        #   This parameter allows you to specify a level of detail in the
        #   information that is posted back while the course is being taken. It
        #   may be one of three values: 'course' (course summary), 'activity'
        #   (activity summary), or 'full' (full detail), and is set to 'course'
        #   by default. The information will be posted as JSON using the same
        #   schema as what is returned in the /progress and /progress/detail
        #   endpoints.
        #
        # @return [ScormEngine::Response]
        #
        def post_registration(options = {})
          require_options(options, :course_id, :registration_id, [:learner, :id], [:learner, :first_name], [:learner, :last_name])

          options = options.dup

          body = {
            courseId: options[:course_id],
            registrationId: options[:registration_id],
            learner: {
              id: options[:learner][:id],
              firstName: options[:learner][:first_name],
              lastName: options[:learner][:last_name],
            },
          }

          if options[:post_back]
            body[:postBack] = {
              authType: options[:post_back][:auth_type],
              userName: options[:post_back][:user_name],
              password: options[:post_back][:password],
              resultsFormat: options[:post_back][:results_format],
            }.reject { |_k, v| v.nil? }
          end

          response = post("registrations", {}, body)

          Response.new(raw_response: response)
        end
      end

      #
      # Returns the link to use to launch this registration
      #
      # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__launchLink_get
      #
      # @param [Hash] options
      #
      # @option options [String] :registration_id
      #   The ID of the registration.
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
      def get_registration_launch_link(options = {})
        require_options(options, :registration_id)

        options = options.dup
        registration_id = options.delete(:registration_id)
        options[:redirectOnExitUrl] = options.delete(:redirect_on_exit_url) if options.key?(:redirect_on_exit_url)

        response = get("registrations/#{registration_id}/launchLink", options)

        result = response.success? ? response.body["launchLink"] : nil

        Response.new(raw_response: response, result: result)
      end
    end
  end
end
