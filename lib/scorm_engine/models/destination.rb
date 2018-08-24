module ScormEngine
  module Models
    class Destination < Base
      # @attr
      # The ID of this destination.
      # @return [String]
      attr_accessor :id

      # @attr
      # The name of this destination.
      # @return [String]
      attr_accessor :name

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]

        # get_destinations (plural) returns values in a nested 'data' field.
        # get_destination (singular) does not.
        data = options["data"] || options
        this.name = data["name"]

        this
      end
    end
  end
end
