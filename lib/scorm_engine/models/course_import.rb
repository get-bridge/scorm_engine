module ScormEngine
  module Models
    class CourseImport < Base
      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :status, :parser_warnings, :course

      def self.new_from_api(options = {})
        this = new
        this.options = options.dup

        if options.key?("importResult")
          this.id = options["result"]
          this.status = options.fetch("importResult", {})["status"]&.upcase
          this.parser_warnings = options.fetch("importResult", {})["parserWarnings"]
        else
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
