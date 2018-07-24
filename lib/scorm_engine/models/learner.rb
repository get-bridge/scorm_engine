module ScormEngine
  module Models
    class Learner
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :first_name, :last_name

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.first_name = options["firstName"]
        this.last_name = options["lastName"]

        this
      end
    end
  end
end
