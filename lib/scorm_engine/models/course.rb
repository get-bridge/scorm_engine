require "time"

module ScormEngine
  module Models
    class Course
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :version, :title, :registration_count, :updated, :description,
                    :scaled_passing_score

      # @attr
      # The course's learning standard.
      # @return [String] (SCORM_11, SCORM_12, SCORM_2004_2ND_EDITION, SCORM_2004_3RD_EDITION, SCORM_2004_4TH_EDITION, AICC, XAPI, CMI5)
      attr_accessor :course_learning_standard

      # @attr
      # The web path at which the course's contents is hosted. For AICC
      # courses, refer to the href proprety of the child activities as this
      # value will not be available.
      # @return [String]
      attr_accessor :web_path

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]
        this.version = options["version"]
        this.title = get_title_from_api(options)
        this.registration_count = options["registrationCount"]
        this.updated = Time.parse(options["updated"]) if options.key?("updated")
        this.description = options.fetch("metadata", {})["description"]
        this.scaled_passing_score = get_scaled_passing_score_from_api(options)
        this.course_learning_standard = options["courseLearningStandard"]
        this.web_path = options["webPath"]

        this
      end

      #
      # Extract and sanitize the title from the API options.
      #
      # Special consideration is given to two commonly found, but useless
      # titles which if found will result in a blank title.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [String]
      #
      def self.get_title_from_api(options = {})
        title = ScormEngine::Utils.sanitized_text(options["title"])
        title = "" if ["Title", "Captivate E-Learning Course"].include?(title)
        title
      end

      #
      # Extract and normalize the scaled passing score from the API options.
      #
      # @param [Hash] options
      #   The API options hash
      #
      # @return [Integer]
      #   An integer between 0 and 100 or nil if undefined.
      #
      def self.get_scaled_passing_score_from_api(options = {})
        first_child = options.fetch("rootActivity", {}).fetch("children", [{}]).first
        score = first_child.is_a?(Hash) ? first_child["scaledPassingScore"] : nil
        return if score.nil?
        score = score.to_f
        score *= 100 if score <= 1.0
        score.to_i
      end
    end
  end
end
