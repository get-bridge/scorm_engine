require "date"

module ScormEngine
  module Models
    class Dispatch < Base
      # @attr
      # The external identification of this dispatch.
      # @return [String]
      attr_accessor :id

      # @attr
      # The external identification of the destination.
      # @return [String]
      attr_accessor :destination_id

      # @attr
      # The external identification of the course.
      # @return [String]
      attr_accessor :course_id

      # @attr
      # If true, then new registrations can be created for this dispatch.
      # @return [Boolean]
      attr_accessor :allow_new_registrations

      # @attr
      # If true, then a new registration instance will be created if the client
      # LMS doesn't provide launch data for an existing one. Otherwise, the
      # same instance will always be used for the given cmi.learner_id.
      # @return [Boolean]
      attr_accessor :instanced

      # @attr
      # The maximum number of registrations that can be created for this
      # dispatch, where '0' means 'unlimited registrations'.
      # @return [Integer]
      attr_accessor :registration_cap

      # @attr
      # The number of registrations created for this dispatch.
      # @return [Integer]
      attr_accessor :registration_count

      # @attr
      # The date after which this dispatch will be disabled as an ISO 8601
      # string, or "none" for no expiration date.
      # @return [Time]
      attr_accessor :expiration_date

      # @attr
      # If true, then this dispatch can be launched.
      # @return [Boolean]
      attr_accessor :enabled

      # @attr
      # Serialized external configuration information to include when launching
      # the dispatched package.
      # @return [String]
      attr_accessor :external_config

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]

        # get_dispatches (plural) returns values in a nested 'data' field.
        # get_dispatches (singular) does not.
        data = options["data"] || options
        this.destination_id = data["destinationId"]
        this.course_id = data["courseId"]
        this.allow_new_registrations = data["allowNewRegistrations"]
        this.instanced = data["instanced"]
        this.registration_cap = data["registrationCap"]&.to_i
        this.registration_count = data["registrationCount"]&.to_i
        this.expiration_date = get_expiration_date(data)
        this.enabled = data["enabled"]
        this.external_config = data["externalConfig"]

        this
      end

      #
      # Extract and normalize the expiration date from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Time]
      #   a date/time or nil if undefined.
      #
      def self.get_expiration_date(options = {})
        expiration_date = options["expirationDate"]
        return if expiration_date.nil? || expiration_date == "none"
        Time.zone.parse(expiration_date)
      end
    end
  end
end
