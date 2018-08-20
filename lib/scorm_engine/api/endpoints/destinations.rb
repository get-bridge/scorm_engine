module ScormEngine
  module Api
    module Endpoints
      module Destinations

        #
        # Get a list of destinations.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations_get
        #
        # @param [Hash] options
        #
        # @option options [String] :course_id
        #   Limit the results to destinations that have dispatches of the specified course.
        #
        # @option options [DateTime] :since
        #   Only destinations updated since the specified ISO 8601 TimeStamp
        #   (inclusive) are included. If a time zone is not specified, the
        #   server's time zone will be used.
        #
        # @return [Enumerator<ScormEngine::Models::Destination>]
        #
        def get_destinations(options = {})
          options = options.dup

          response = get("destinations", options)

          result = Enumerator.new do |enum|
            loop do
              response.success? && response.body["destinations"].each do |destination|
                enum << ScormEngine::Models::Destination.new_from_api(destination)
              end
              break if !response.success? || response.body["more"].nil?
              response = get(response.body["more"])
            end
          end

          Response.new(raw_response: response, result: result)
        end

        #
        # Create a destination.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations_post
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The destination ID.
        #
        # @option options [String] :name (:destination_id)
        #   The destination's name.
        #
        # @return [ScormEngine::Response]
        #
        def post_destination(options = {})
          require_options(options, :destination_id)

          options = options.dup
          options[:name] ||= options[:destination_id]

          body = {
            destinations: [
              id: options[:destination_id].to_s,
              data: {
                name: options[:name].to_s,
              },
            ]
          }

          response = post("destinations", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Get a destination.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations__destinationId__get
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The ID of the destination to get.
        #
        # @return [ScormEngine::Models::Destination]
        #
        def get_destination(options = {})
          require_options(options, :destination_id)

          response = get("destinations/#{options[:destination_id]}")

          # merge options to pick up destination_id which isn't passed back in the response
          result = response.success? ? ScormEngine::Models::Destination.new_from_api(options.merge(response.body)) : nil

          Response.new(raw_response: response, result: result)
        end

        #
        # Update a destination.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations__destinationId__put
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The destination ID.
        #
        # @option options [String] :name
        #   The destination's new name.
        #
        # @return [ScormEngine::Response]
        #
        def put_destination(options = {})
          require_options(options, :destination_id, :name)

          options = options.dup

          body = {
            name: options[:name],
          }

          response = put("destinations/#{options[:destination_id]}", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Delete a destination.
        #
        # Deleting a destination will also delete all dispatches for that
        # destination.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations_delete
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The ID of the destination to delete.
        #
        # @return [ScormEngine::Response]
        #
        def delete_destination(options = {})
          require_options(options, :destination_id)

          response = delete("destinations/#{options[:destination_id]}")

          Response.new(raw_response: response)
        end

        #
        # Enable or disable all related dispatches.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations__destinationId__dispatches_enabled_post
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The ID of the destination
        #
        # @option options [Boolean] :enabled
        #   The enabledness of all related dispatches
        #
        # @return [ScormEngine::Response]
        #
        def post_destination_dispatches_enabled(options = {})
          require_options(options, :destination_id, :enabled)

          body = options[:enabled].to_s

          response = post("destinations/#{options[:destination_id]}/dispatches/enabled", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Enable or disable registration instancing.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations__destinationId__dispatches_registrationInstancing_post
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The ID of the destination to delete.
        #
        # @option options [Boolean] :enabled
        #   The enabledness of the registration instancing
        #
        # @return [ScormEngine::Response]
        #
        def post_destination_dispatches_registration_instancing(options = {})
          require_options(options, :destination_id, :enabled)

          body = options[:enabled].to_s

          response = post("destinations/#{options[:destination_id]}/dispatches/registrationInstancing", {}, body)

          Response.new(raw_response: response)
        end

        #
        # Get an aggregate count of all related dispatch registrations.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html#tenant__destinations__destinationId__dispatches_registrationCount_get
        #
        # @param [Hash] options
        #
        # @option options [String] :destination_id
        #   The ID of the destination to delete.
        #
        # @return [Integer]
        #
        def get_destination_dispatches_registration_count(options = {})
          require_options(options, :destination_id)

          response = get("destinations/#{options[:destination_id]}/dispatches/registrationCount")

          result = response.success? ? response.body.to_i : nil

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
