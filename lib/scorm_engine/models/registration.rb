module ScormEngine
  module Models
    # rubocop:disable Metrics/AbcSize
    class Registration < Base
      # @attr
      # The external identification of the registration.
      # @return [String]
      attr_accessor :id

      # @attr
      # Has this registration been completed?
      # @return [String] (UNKNOWN COMPLETED INCOMPLETE)
      attr_accessor :registration_completion

      # @attr
      # Has this registration been passed?
      # @return [String] (Unknown Passed Failed)
      attr_accessor :registration_success

      # @attr
      # A decimal value between 0 and 1 representing the percentage of this
      # course that the learner has completed so far, if known. Note: for
      # learning standards other than SCORM 2004 4th Edition, this value is
      # based on the percentage of activities completed/passed. This means that
      # single-activity courses in those standards will always return either 0
      # or 1.
      # @return [Float] (Unknown Passed Failed)
      attr_accessor :registration_completion_amount

      # @attr
      # Instance of this registration (typically used for reoccurring training), starts at 0.

      # @return [String]
      attr_accessor :instance

      # @attr
      #
      # @return [Time]
      attr_accessor :updated

      # @attr
      # How long the learner spent taking this registration, in seconds.
      # @return [Integer]
      attr_accessor :total_seconds_tracked

      # @attr
      # Scaled score between 0 and 100.
      # @return [Float]
      attr_accessor :score

      # @attr
      #
      # @return [ScormEngine::Models::Course]
      attr_accessor :course

      # @attr
      #
      # @return [ScormEngine::Models::Learner]
      attr_accessor :learner

      # @attr
      #
      # @return [ScormEngine::Models::RegistrationActivityDetail]
      attr_accessor :activity_details

      # @attr
      # Time of the learner's first interaction with this registration.
      # @return [Time]
      attr_accessor :first_access_date

      # @attr
      # Time of the learner's last interaction with this registration.
      # @return [Time]
      attr_accessor :last_access_date

      # @attr
      # Time of the learner's first completion of this registration.
      # @return [Time]
      attr_accessor :completed_date

      # @attr
      # Time of the creation of this registration.
      # @return [Time]
      attr_accessor :created_date

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.instance = options["instance"]
        this.updated = Time.zone.parse(options["updated"]) if options.key?("updated")
        this.registration_completion = options["registrationCompletion"]&.upcase
        this.registration_success = options["registrationSuccess"]&.upcase
        this.total_seconds_tracked = options["totalSecondsTracked"]&.to_i
        this.first_access_date = Time.zone.parse(options["firstAccessDate"]) if options.key?("firstAccessDate")
        this.last_access_date = Time.zone.parse(options["lastAccessDate"]) if options.key?("lastAccessDate")
        this.created_date = Time.zone.parse(options["createdDate"]) if options.key?("createdDate")
        this.updated = Time.zone.parse(options["updated"]) if options.key?("updated")
        this.registration_completion_amount = options["registrationCompletionAmount"].to_f # Sometimes it returns "NaN"

        this.score = get_score_from_api(options)
        this.completed_date = get_completed_at_from_api(options)

        this.activity_details = RegistrationActivityDetail.new_from_api(options["activityDetails"]) if options.key?("activityDetails")
        this.course = Course.new_from_api(options["course"]) if options.key?("course")
        this.learner = Learner.new_from_api(options["learner"]) if options.key?("learner")

        this
      end

      #
      # Has this registration been completed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def complete?
        return nil if registration_completion == "UNKNOWN"
        registration_completion == "COMPLETED"
      end

      #
      # Is this registration incomplete?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def incomplete?
        return nil if registration_completion == "UNKNOWN"
        registration_completion == "INCOMPLETE"
      end

      #
      # Has this registration been passed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if success status is unknown.
      #
      def passed?
        return nil if registration_success == "UNKNOWN"
        registration_success == "PASSED"
      end

      #
      # Has this registration failed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if success status is unknown.
      #
      def failed?
        return nil if registration_success == "UNKNOWN"
        registration_success == "FAILED"
      end

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

      #
      # Extract and normalize the completed date from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Time]
      #   a date/time or nil if undefined.
      #
      def self.get_completed_at_from_api(options = {})
        completed_date = options["completedDate"]
        completed_date ||= options.fetch("score", {})["completedDate"]
        return if completed_date.nil?
        Time.zone.parse(completed_date)
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
