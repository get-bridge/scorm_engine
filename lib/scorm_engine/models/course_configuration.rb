module ScormEngine
  module Models
    class CourseConfiguration < Base
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
        return {} if options.nil?

        # API v2 uses "settingItems", API v1 uses "configurationItems"
        configuration_items = options["settingItems"] || options["configurationItems"]
        return {} unless configuration_items.respond_to?(:reduce)
        
        configuration_items.reduce({}) do |m, o|
          # API v2 uses "effectiveValue", API v1 uses "value"
          value = o["effectiveValue"] || o["value"]
          m[o["id"]] = value
          m
        end
      end
    end
  end
end
