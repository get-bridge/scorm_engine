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
        # @option options [DateTime] :before
        #   Only registrations updated before the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @option options [DateTime] :since
        #   Only registrations updated since the specified ISO 8601 TimeStamp (inclusive)
        #   are included. If a time zone is not specified, the server's time zone will be
        #   used.
        #
        # @option options [Integer] :course_id
        #   Only registrations for the specified course id will be included.
        #
        # @option options [Integer] :learner_id
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
        
      end
    end
  end
end
