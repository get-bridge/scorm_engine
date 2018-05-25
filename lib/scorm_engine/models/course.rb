require "time"

module ScormEngine
  module Models
    class Course
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :version, :title, :registration_count, :updated, :description 

      def self.new_from_api(options = {})
        this = new
        this.options = options.dup
        this.id = options["id"]
        this.version = options["version"]
        this.title = options["title"]
        this.registration_count = options["registrationCount"]
        this.updated = Time.parse(options["updated"]) if options.key?("updated")
        this.description = options.fetch("metadata", {})["description"]
        this
      end
    end
  end
end
