require "date"

module ScormEngine
  module Models
    class Dispatch
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :destination_id, :course_id, :allow_new_registrations,
                    :instanced, :registration_cap, :expiration_date, :external_config

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.destination_id = options["data"]["destinationId"]
        this.course_id = options["data"]["courseId"]
        this.allow_new_registrations = options["data"]["allowNewRegistrations"]
        this.instanced = options["data"]["instanced"]
        this.registration_cap = options["data"]["registrationCap"]&.to_i
        this.expiration_date = get_expiration_date(options)
        this.external_config = options["data"]["externalConfig"]

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
        expiration_date = options.fetch("data", {})["expirationDate"]
        return if expiration_date.nil?
        Date.parse(expiration_date)
      end
    end
  end
end
