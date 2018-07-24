module ScormEngine
  module Models
    class CourseConfiguration
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :settings

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.settings = get_settings_from_api(options)
        this
      end

      private

      #
      # Extract and normalize the settings from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @returns [Hash]
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
