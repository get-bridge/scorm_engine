module ScormEngine
  module Models
    class RegistrationActivityDetail < Base
      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :children, :runtime_interactions

      # @attr
      # Represents whether the current attempt on the activity has been completed.
      # @return [String] (UNKNOWN COMPLETED INCOMPLETE)
      attr_accessor :activity_completion

      # @attr
      # Represents whether the previous attempt on the activity has been completed.
      # @return [String] (Unknown Completed Incomplete)
      attr_accessor :previous_attempt_completion

      # @attr
      # Pass/fail status of primary objective for this activity.
      # @return [String] (UNKNOWN PASSED FAILED)
      attr_accessor :activity_success

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.activity_completion = options["activityCompletion"]
        this.previous_attempt_completion = options["previousAttemptCompletion"]
        this.activity_success = options["activitySuccess"]

        this.runtime_interactions = get_runtime_interactions_from_api(options)

        this.children = options.fetch("children", []).map { |e| new_from_api(e) }

        this
      end

      #
      # Return a flattened array of all runtime interactions
      #
      # @return [Array<RegistrationRuntimeInteraction>]
      #
      def all_runtime_interactions
        (runtime_interactions + children.map(&:all_runtime_interactions)).flatten
      end

      def self.get_runtime_interactions_from_api(options)
        options
          .fetch("runtime", {})
          .fetch("runtimeInteractions", [])
          .map { |e| RegistrationRuntimeInteraction.new_from_api(e) }
      end

      #
      # Has this activity been completed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def complete?
        return nil if activity_completion == "UNKNOWN"
        activity_completion == "COMPLETED"
      end

      #
      # Is this activity incomplete?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def incomplete?
        return nil if activity_completion == "UNKNOWN"
        activity_completion == "INCOMPLETE"
      end

      #
      # Has the previous attempt of this activity been completed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def previous_attempt_complete?
        return nil if previous_attempt_completion == "Unknown"
        previous_attempt_completion == "Completed"
      end

      #
      # Is the previous attempt of this previous_attempt incomplete?
      #
      # @return [Boolean]
      #   Returns true, false or nil if completion status is unknown.
      #
      def previous_attempt_incomplete?
        return nil if previous_attempt_completion == "Unknown"
        previous_attempt_completion == "Incomplete"
      end

      #
      # Has this activity been passed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if success status is unknown.
      #
      def passed?
        return nil if activity_success == "UNKNOWN"
        activity_success == "PASSED"
      end

      #
      # Has this activity failed?
      #
      # @return [Boolean]
      #   Returns true, false or nil if success status is unknown.
      #
      def failed?
        return nil if activity_success == "UNKNOWN"
        activity_success == "FAILED"
      end

    end
  end
end
