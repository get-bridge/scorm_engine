module ScormEngine
  module Models
    class DispatchZip
      attr_accessor :options
      private :options

      attr_accessor :dispatch_id, :type, :filename, :body

      def initialize(options = {})
        @options = options.dup
        @dispatch_id = options[:dispatch_id]
        @type = options[:type]
        @filename = options[:filename]
        @body = options[:body]
      end
    end
  end
end
