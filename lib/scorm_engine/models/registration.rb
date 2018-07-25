module ScormEngine
  module Models
    class Registration
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :instance, :updated, :registration_completion, :registration_success,
        :total_seconds_tracked, :first_access_date, :last_access_date, :score, :course, :learner

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.instance = options["instance"]
        this.updated = Time.parse(options["updated"]) if options.key?("updated")
        this.registration_completion = options["registrationCompletion"]
        this.registration_success = options["registrationSuccess"]
        this.total_seconds_tracked = options["totalSecondsTracked"]
        this.first_access_date = Time.parse(options["firstAccessDate"]) if options.key?("firstAccessDate")
        this.last_access_date = Time.parse(options["lastAccessDate"]) if options.key?("lastAccessDate")

        this.score = get_score_from_api(options)

        this.course = Course.new_from_api(options["course"]) if options.key?("course")
        this.learner = Learner.new_from_api(options["learner"]) if options.key?("learner")

        this
      end

      private

      #
      # Extract and normalize the scaled passing score from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Float]
      #   A float between 0 and 100 or nil if undefined.
      #
      def self.get_score_from_api(options = {})
        score = options.fetch("score", {})["scaled"]
        return if score.nil?
        score.to_f
      end
    end
  end
end
