require "date"

module ScormEngine
  module Models
    class DispatchRegistrationCount < Base
      # @attr
      # The external identification of this dispatch.
      # @return [String]
      attr_accessor :id

      # @attr
      # The registration count for this dispatch.
      # @return [Integer]
      attr_accessor :registration_count

      # @attr
      # The date and time of the last count reset, if any.
      # @return [DateTime]
      attr_accessor :last_reset_at

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.registration_count = options["registrationCount"].to_i
        this.last_reset_at = get_last_reset_time(options)

        this
      end

      #
      # Extract and normalize the last reset datetime from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Time]
      #   a date/time or nil if undefined.
      #
      def self.get_last_reset_time(options = {})
        time = options["lastResetTime"]
        return if time.nil? || time == "none"

        Time.zone.parse(time)
      end
    end
  end
end
