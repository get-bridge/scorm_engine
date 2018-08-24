module ScormEngine
  module Models
    class RegistrationConfiguration < Base
      # @attr
      #
      # @return [Hash]
      attr_accessor :settings

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.settings = get_settings_from_api(options)
        this
      end

      #
      # Extract and normalize the settings from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Hash]
      #   A hash of key/value pairs.
      #
      def self.get_settings_from_api(options = {})
        options["configurationItems"].reduce({}) do |m, o|
          m[o["id"]] = o["value"]
          m
        end
      end
    end
  end
end
