module ScormEngine
  module Models
    class Base
      attr_accessor :options
      private :options

      #
      # Return a hashified representation of the object.
      #
      # This hash should not be used to access individual data elements
      # unavailable via standard accessors, but only for use in marshaling
      # of the data.
      #
      # @return [Hash]
      #
      def to_hash
        options
      end
    end
  end
end
