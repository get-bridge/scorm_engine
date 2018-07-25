module ScormEngine
  module Models
    class RegistrationLaunchHistory
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :instance_id, :launch_time, :exit_time,
                    :completion_status, :success_status, :total_seconds_tracked,
                    :last_runtime_update

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]

        this.id = options["id"]
        this.instance_id = options["instanceId"].to_i
        this.launch_time = parse_time(options["launchTimeUtc"])
        this.exit_time = parse_time(options["exitTimeUtc"])
        this.completion_status = options["completionStatus"]
        this.success_status = options["successStatus"]
        this.total_seconds_tracked = options["totalSecondsTracked"]
        this.last_runtime_update = parse_time(options["lastRuntimeUpdateUtc"])

        this
      end

      private 

      def self.parse_time(string)
        return nil if string.nil? || string.empty?
        Time.strptime("#{string} UTC", "%m/%d/%Y %H:%M:%S %p %Z")
      rescue
        Time.parse(string)
      end
    end
  end
end
