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

        configuration_items = options["configurationItems"]
        return {} unless configuration_items.respond_to?(:reduce)
        configuration_items.reduce({}) do |m, o|
          m[o["id"]] = o["value"]
          m
        end
      end
    end
  end
end
