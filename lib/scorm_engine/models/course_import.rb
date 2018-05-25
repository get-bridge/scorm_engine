module ScormEngine
  module Models
    class CourseImport
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :status, :parser_warnings, :course

      def self.new_from_api(options = {})
        this = new
        this.options = options.dup
        
        if options.key?("importResult")
          this.id = options["result"]
          this.status = options.fetch("importResult", {})["status"]
          this.parser_warnings = options.fetch("importResult", {})["parserWarnings"]
        else
          this.id = options["jobId"]
          this.status = options["status"]
          this.course = Course.new_from_api(options["course"])
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
