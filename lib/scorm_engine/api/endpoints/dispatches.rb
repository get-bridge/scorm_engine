module ScormEngine
  module Api
    module Endpoints
      module Dispatches

        #
        # Get a list of dispatches.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches_get
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   Limit the results to dispatches of the specified course.
        #
        # @option options [DateTime] :since
        #   Only dispatches updated since the specified ISO 8601 TimeStamp
        #   (inclusive) are included. If a time zone is not specified, the
        #   server's time zone will be used.
        #
        # @return [Enumerator<ScormEngine::Models::Dispatch>]
        #
        def get_dispatches(options = {})
          options = options.dup

          response = get("dispatches", options)

          result = Enumerator.new do |enum|
            loop do
              response.success? && response.body["dispatches"].each do |course|
                enum << ScormEngine::Models::Dispatch.new_from_api(course)
              end
              break if !response.success? || response.body["more"].nil?
              response = get(response.body["more"])
            end
          end

          Response.new(raw_response: response, result: result)
        end

        #
        # Create a dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches_post
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The dispatch ID.
        #
        # @option options [String] :destination_id
        #   The destination ID.
        #
        # @option options [String] :course_id
        #   The course ID.
        #
        # @option options [Boolean] :allow_new_registrations (false)
        #   If true, then new registrations can be created for this dispatch.
        #
        # @option options [Boolean] :instanced (false)
        #   If true, then a new registration instance will be created if the
        #   client LMS doesn't provide launch data for an existing one.
        #   Otherwise, the same instance will always be used for the given
        #   cmi.learner_id.
        #
        # @option options [Integer] :registration_cap (0)
        #   The maximum number of registrations that can be created for this
        #   dispatch, where '0' means 'unlimited registrations'.
        #
        # @option options [Date] :expiration_date ("none")
        #   The date after which this dispatch will be disabled as an ISO 8601
        #   string, or "none" for no expiration date.
        #
        # @option options [String] :external_config ("")
        #   Serialized external configuration information to include when
        #   launching the dispatched package.
        #
        # @return [ScormEngine::Response]
        #
        def post_dispatch(options = {})
          require_options(options, :dispatch_id, :destination_id, :course_id)

          options = coerce_dispatch_options(options.dup)

          body = {
            dispatches: [
              id: options[:dispatch_id],
              data: {
                destinationId: options[:destination_id],
                courseId: options[:course_id],
                allowNewRegistrations: options[:allow_new_registrations],
                instanced: options[:instanced],
                registrationCap: options[:registration_cap],
                expirationDate: options[:expiration_date],
                externalConfig: options[:external_config],
              },
            ]
          }

          response = post("dispatches", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Get a dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__get
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The ID of the dispatch to get.
        #
        # @return [ScormEngine::Models::Dispatch]
        #
        def get_dispatch(options = {})
          require_options(options, :dispatch_id)

          response = get("dispatches/#{options[:dispatch_id]}")

          # merge options to pick up dispatch_id which isn't passed back in the response
          result = response.success? ? ScormEngine::Models::Dispatch.new_from_api({ "id" => options[:dispatch_id] }.merge(response.body)) : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Update a dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__put
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The dispatch ID.
        #
        # @option options [String] :destination_id
        #   The destination ID.
        #
        # @option options [String] :course_id
        #   The course ID.
        #
        # @option options [Boolean] :allow_new_registrations
        #   If true, then new registrations can be created for this dispatch.
        #
        # @option options [Boolean] :instanced
        #   If true, then a new registration instance will be created if the
        #   client LMS doesn't provide launch data for an existing one.
        #   Otherwise, the same instance will always be used for the given
        #   cmi.learner_id.
        #
        # @option options [Integer] :registration_cap
        #   The maximum number of registrations that can be created for this
        #   dispatch, where '0' means 'unlimited registrations'.
        #
        # @option options [Date] :expiration_date
        #   The date after which this dispatch will be disabled as an ISO 8601
        #   string, or "none" for no expiration date.
        #
        # @option options [String] :external_config ("")
        #   Serialized external configuration information to include when
        #   launching the dispatched package.
        #
        # @return [ScormEngine::Response]
        #
        def put_dispatch(options = {})
          require_options(options, :dispatch_id, :destination_id, :course_id,
                          :allow_new_registrations, :instanced, :registration_cap, :expiration_date)

          options = coerce_dispatch_options(options.dup)

          body = {
            destinationId: options[:destination_id],
            courseId: options[:course_id],
            allowNewRegistrations: options[:allow_new_registrations],
            instanced: options[:instanced],
            registrationCap: options[:registration_cap],
            expirationDate: options[:expiration_date],
            externalConfig: options[:external_config],
          }

          response = put("dispatches/#{options[:dispatch_id]}", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Delete a dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__delete
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The ID of the dispatch to delete.
        #
        # @return [ScormEngine::Response]
        #
        def delete_dispatch(options = {})
          require_options(options, :dispatch_id)

          response = delete("dispatches/#{options[:dispatch_id]}")

          Response.new(raw_response: response)
        end

        #
        # Get the enabled status of a dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__enabled_get
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The ID of the dispatch to delete.
        #
        # @return [ScormEngine::Response]
        #
        def get_dispatch_enabled(options = {})
          require_options(options, :dispatch_id)

          response = get("dispatches/#{options[:dispatch_id]}/enabled")

          result = response.success? ? response.body : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Enable or disable the dispatch.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__enabled_put
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The ID of the dispatch
        #
        # @option options [Boolean] :enabled
        #   The enabledness of the dispatch
        #
        # @return [ScormEngine::Response]
        #
        def put_dispatch_enabled(options = {})
          require_options(options, :dispatch_id, :enabled)

          body = options[:enabled].to_s

          response = put("dispatches/#{options[:dispatch_id]}/enabled", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Get the ZIP dispatch package.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__dispatches__dispatchId__zip_get
        #
        # @param [Hash] options
        #
        # @option options [String] :dispatch_id
        #   The ID of the dispatch to delete.
        #
        # @option options [String] :type (SCORM12)
        #   The type of dispatch package to export (SCORM12, SCORM2004-3RD or AICC)
        #
        # @return [ScormEngine::Models::DispatchZip]
        #
        def get_dispatch_zip(options = {})
          require_options(options, :dispatch_id)

          options = options.dup
          dispatch_id = options.delete(:dispatch_id)
          options[:type] = options[:type]&.upcase || "SCORM12"

          response = get("dispatches/#{dispatch_id}/zip", options)

          result = if response.success?
                     ScormEngine::Models::DispatchZip.new(
                       dispatch_id: dispatch_id,
                       type: options[:type],
                       filename: response.headers["content-disposition"].match(/; filename="(.*?)"/)&.captures&.first,
                       body: response.body,
                     )
                   end

          Response.new(raw_response: response, result: result)
        end

        private

        def coerce_dispatch_options(options = {})
          options[:allow_new_registrations] = !!options[:allow_new_registrations]
          options[:instanced] = !!options[:instanced]
          options[:registration_cap] = [0, options[:registration_cap].to_i].max
          options[:expiration_date] = coerce_expiration_date(options[:expiration_date])
          options
        end

        def coerce_expiration_date(date)
          return date if date == "none"
          date = date.is_a?(String) ? Date.parse(date) : date
          date&.iso8601 # might be nil
        rescue ArgumentError # unparsable date string
          raise(ArgumentError, "Invalid option expiration_date")
        end
      end
    end
  end
end
