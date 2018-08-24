module ScormEngine
  module Models
    class RegistrationRuntimeInteraction < Base
      # @attr
      # The interaction ID.
      # @return [String]
      attr_accessor :id

      # @attr
      # The interaction type.
      # @return [String] (Undefined, TrueFalse, Choice, FillIn, LongFillIn, Likert, Matching, Performance, Sequencing, Numeric, Other)
      attr_accessor :type

      # @attr
      # A textual description of the interaction.
      # @return [String]
      attr_accessor :description

      # @attr
      # The timestamp of when the interaction was reported, in the format
      # provided by the SCO.
      # @return [Time]
      attr_accessor :timestamp

      # @attr
      # The correct responses to this interaction.
      # @return [Array<String>]
      attr_accessor :correct_responses

      # @attr
      # The correct responses to this interaction.
      # @return [String]
      attr_accessor :learner_response

      # @attr
      #
      # @return [String]
      attr_accessor :result

      # @attr
      # The weight this interaction carries relative to the other interactions
      # in the SCO.
      # @return [String]
      attr_accessor :weighting

      # @attr
      # Iso8601TimeSpan representing the amount of time it took for the learner
      # to make the interaction, i.e. how long it took the learner to answer
      # the question.
      # @return [String]
      attr_accessor :latency

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.type = options["type"]&.upcase
        this.description = get_description_from_api(options)
        this.timestamp = get_timestamp_from_api(options)
        this.correct_responses = options["correctResponses"]
        this.learner_response = get_learner_response_from_api(options)
        this.result = options["result"]
        this.weighting = options["weighting"].to_f
        this.latency = options["latency"]

        this
      end

      # The amount of time it took for the learner to make the interaction,
      # i.e. how long it took the learner to answer the question. In seconds.
      #
      # @return [Integer]
      def latency_in_seconds
        h, m, s = latency.split(":")
        h.to_i * 3600 + m.to_i * 60 + s.to_i
      end

      def self.get_description_from_api(options)
        description = options["description"].to_s.gsub(/\s+/, " ").strip
        description = nil if description.empty? || description == "null"
        description
      end

      def self.get_learner_response_from_api(options)
        options["learnerResponse"].to_s.gsub(/\s+/, " ").strip
      end

      def self.get_timestamp_from_api(options)
        timestamp = options["timestampUtc"]
        return if timestamp.nil? || timestamp.empty?
        Time.parse(timestamp)
      end
    end
  end
end
