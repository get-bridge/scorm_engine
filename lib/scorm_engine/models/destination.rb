module ScormEngine
  module Models
    class Destination
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :name

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]

        # get_destinations (plural) returns values in a nested 'data' field.
        # get_destination (singular) does not.
        this.name = if options.key?("data")
                      options["data"]["name"]
                    else
                      options["name"]
                    end

        this
      end
    end
  end
end
