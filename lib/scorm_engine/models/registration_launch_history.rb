module ScormEngine
  module Models
    class RegistrationLaunchHistory < Base
      # @attr
      # The external identification of the registration.
      # @return [String]
      attr_accessor :id

      # @attr
      #
      # @return [String]
      attr_accessor :instance_id

      # @attr
      #
      # @return [Time]
      attr_accessor :launch_time

      # @attr
      #
      # @return [Time]
      attr_accessor :exit_time

      # @attr
      #
      # @return [String] (COMPLETED, INCOMPLETE, UNKNOWN)
      attr_accessor :completion_status

      # @attr
      #
      # @return [String] (FAILED, PASSED, UNKNOWN)
      attr_accessor :success_status

      # @attr
      #
      # @return [Integer]
      attr_accessor :total_seconds_tracked

      # @attr
      #
      # @return [Time]
      attr_accessor :last_runtime_update

      # @attr
      #
      # @return [Float]
      attr_accessor :score

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup

        this.id = options["id"]
        this.instance_id = options["instanceId"].to_i
        this.launch_time = parse_time(options["launchTimeUtc"])
        this.exit_time = parse_time(options["exitTimeUtc"])
        this.completion_status = options["completionStatus"]&.upcase
        this.success_status = options["successStatus"]&.upcase
        this.last_runtime_update = parse_time(options["lastRuntimeUpdateUtc"])

        this.score = get_score_from_api(options)
        this.total_seconds_tracked = get_total_seconds_tracked_from_api(options)

        this
      end

      #
      # Extract and convert various time formats.
      #
      # @see https://basecamp.com/2819363/projects/15019959/messages/79529838
      #
      # @param [String] string
      #   The string to be parsed into a time.
      #
      # @return [Time]
      #
      def self.parse_time(string)
        return nil if string.blank?
        Time.strptime("#{string} UTC", "%m/%d/%Y %H:%M:%S %p %Z")
      rescue StandardError
        Time.zone.parse(string)
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
      #
      def self.get_total_seconds_tracked_from_api(options = {})
        # There is a bug in the API that returns a trailing space sometimes.
        # I swear I also saw `totalSecondsTracked` as part of `score`, but can't find it now.
        # However, since I intentionally did it I'm going to leave it for now.
        seconds = options["totalSecondsTracked"]
        seconds ||= options["totalSecondsTracked "]
        score = options.fetch("score", {})
        seconds ||= score["totalSecondsTracked"]
        seconds ||= score["totalSecondsTracked "]
        return if seconds.nil?
        [seconds.to_f, 0].max
      end
    end
  end
end
