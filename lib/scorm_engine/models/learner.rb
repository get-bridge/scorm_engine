module ScormEngine
  module Models
    class Learner < Base
      # @attr
      # The external identification of the learner.
      # @return [String]
      attr_accessor :id

      # @attr
      # The learner's first name.
      # @return [String]
      attr_accessor :first_name

      # @attr
      # The learner's last name.
      # @return [String]
      attr_accessor :last_name

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
