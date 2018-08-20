require_relative "endpoints/about"
require_relative "endpoints/courses"
require_relative "endpoints/courses/configuration"
require_relative "endpoints/courses/import"
require_relative "endpoints/destinations"
require_relative "endpoints/dispatches"
require_relative "endpoints/ping"
require_relative "endpoints/registrations"
require_relative "endpoints/registrations/configuration"
require_relative "endpoints/registrations/launch_history"

module ScormEngine
  module Api
    module Endpoints
      include About
      include Courses
      include Courses::Configuration
      include Courses::Import
      include Destinations
      include Dispatches
      include Ping
      include Registrations
      include Registrations::Configuration
      include Registrations::LaunchHistory

      private

      #
      # Ensure that all of the keys are present in the hash passed and raise an error if not.
      #
      # @example
      #   require_options({foo: 1, bar: {"baz" => 2}}, :foo, [:bar, :baz], :moo)
      #   # will raise an errror due to lack of :moo
      #
      # @param [Hash] haystack
      #   The option hash in which to search for the given, optionally nested, key[s].
      #
      # @param [Array] sets_of_needles
      #   A splat of keys or array of nested keys to search for.
      #
      # @raise [ArgumentError] if any needle isn't found.
      #
      def require_options(haystack = {}, *sets_of_needles)
        sets_of_needles.each { |needles| require_option(haystack, *needles) }
      end

      def require_option(haystack, *needles)
        value = needles.reduce(haystack) { |m, o| value_for_key(m, o) }
        return unless value.nil?
        raise ArgumentError, "Required option #{needles.join("/")} missing"
      end

      def value_for_key(m, o)
        return m[o.to_sym] if m.key?(o.to_sym)
        return m[o.to_s] if m.key?(o.to_s)
        nil
      end
    end
  end
end
