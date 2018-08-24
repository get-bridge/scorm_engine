#
# TODO: Incorporate all the activity props from:
#   http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__progress_get
#   http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__registrations__registrationId__progress_detail_get
#
# TODO: Confirmed they are the only values. Integrate them into the model.
#       registrationCompletion: ["COMPLETED", "INCOMPLETE", "UNKNOWN"]
#       registrationSuccess: ["Unknown", "Passed", "Failed"]
#
module ScormEngine
  module Models
    class Registration < Base
      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :instance, :updated,
        :total_seconds_tracked, :score, :course, :learner, :activity_details,
        :first_access_date, :last_access_date, :completed_date, :created_date

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
        this.created_date = Time.parse(options["createdDate"]) if options.key?("createdDate")
        this.updated = Time.parse(options["updated"]) if options.key?("updated")
        this.registration_completion_amount = options["registrationCompletionAmount"].to_f # Sometimes it returns "NaN"

        this.score = get_score_from_api(options)
        this.completed_date = get_completed_at_from_api(options)

        this.activity_details = RegistrationActivityDetail.new_from_api(options["activityDetails"]) if options.key?("activityDetails")
        this.course = Course.new_from_api(options["course"]) if options.key?("course")
        this.learner = Learner.new_from_api(options["learner"]) if options.key?("learner")

        this
      end

      def progress
        activity_details.activity_count(only_completed: true).to_f / activity_details.activity_count
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
        return nil if registration_success == "Unknown"
        registration_success == "Passed"
      end

      #
      # Has this registration failed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if success status is unknown.
      #
      def failed?
        return nil if registration_success == "Unknown"
        registration_success == "Failed"
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
        Time.parse(completed_date)
      end
    end
  end
end
