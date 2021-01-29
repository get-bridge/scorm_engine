module ScormEngine
  module Models
    class DispatchZip < Base
      # @attr
      # The external identification of the dispatch.
      # @return [String]
      attr_accessor :dispatch_id

      # @attr
      # The type of ZIP package to generate.
      # @return [String] (SCORM12, SCORM2004-3RD, AICC)
      attr_accessor :type

      # @attr
      #
      # @return [String]
      attr_accessor :filename

      # @attr
      #
      # @return [String]
      attr_accessor :body

      # rubocop:disable Lint/MissingSuper
      def initialize(options = {})
        @options = options.dup
        @dispatch_id = options[:dispatch_id]
        @type = options[:type]&.upcase
        @filename = options[:filename]
        @body = options[:body]
      end
      # rubocop:enable Lint/MissingSuper
    end
  end
end
