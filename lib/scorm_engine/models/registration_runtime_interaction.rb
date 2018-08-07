module ScormEngine
  module Models
    class RegistrationRuntimeInteraction
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :type, :description, :timestamp, :correct_responses, :learner_response,
        :result, :weighting, :latency

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.type = options["type"]
        this.description = get_description_from_api(options)
        this.timestamp = get_timestamp_from_api(options)
        this.correct_responses = options["correctResponses"]
        this.learner_response = get_learner_response_from_api(options)
        this.result = options["result"]
        this.weighting = options["weighting"] # TODO: Coerce to numeric? see https://basecamp.com/2819363/projects/15019959/messages/79802980
        this.latency = options["latency"]

        this
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

      def latency_in_seconds
        h, m, s = latency.split(":")
        h.to_i * 3600 + m.to_i * 60 + s.to_i
      end
    end
  end
end
