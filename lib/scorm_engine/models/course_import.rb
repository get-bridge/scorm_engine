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
          # API v2 response structure: status is at top level, importResult contains nested data
          this.id = options["jobId"]
          this.status = options["status"]&.upcase
          this.parser_warnings = options.fetch("importResult", {})["parserWarnings"]
          # Course data is nested in importResult for API v2
          this.course = Course.new_from_api(options.fetch("importResult", {})["course"]) if options.fetch("importResult", {}).key?("course")
        elsif options.key?("result") && options.size == 1
          # Initial import response format: {"result": "job-id"}
          this.id = options["result"]
          this.status = "RUNNING" # Assume running for initial response
        else
          # API v1 response structure or full status response
          this.id = options["jobId"]
          this.status = options["status"]&.upcase
          this.course = Course.new_from_api(options["course"]) if options.key?("course") # unavailable in error states
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
    end
  end
end
