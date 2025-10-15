module ScormEngine
  module Models
    class CourseImport < Base

      # @attr
      # The ID of this course import (not the course id)
      # @return [String]
      attr_accessor :id

      # @attr
      #
      # @return [String] (RUNNING, COMPLETE, ERROR)
      attr_accessor :status

      # @attr
      #
      # @return [Array<String>]
      attr_accessor :parser_warnings

      # @attr
      #
      # @return [ScormEngine::Models::Course]
      attr_accessor :course

      def self.new_from_api(options = {})
        this = new
        this.options = options.dup

        if options.key?("importResult")
          # API v2 response
          import_result = options["importResult"] || {}

          this.id              = options["jobId"] || options["result"]
          this.status          = (options["status"] || import_result["status"])&.upcase
          this.parser_warnings = import_result["parserWarnings"]

          this.course = Course.new_from_api(import_result["course"]) if import_result.key?("course")

        elsif options.keys == ["result"]
          # Initial import response (legacy format: {"result" => "job-id"})
          this.id     = options["result"]
          this.status = "RUNNING"

        else
          # API v1 or full status response
          this.id              = options["jobId"]
          this.status          = options["status"]&.upcase
          this.parser_warnings = options["parserWarnings"]

          this.course = Course.new_from_api(options["course"]) if options.key?("course")
        end

        this
      end

      def running?
        status == "RUNNING"
      end

      def error?
        status == "ERROR"
      end

      def complete?
        status == "COMPLETE"
      end

      def completed?
        status == "COMPLETED"
      end
    end
  end
end
