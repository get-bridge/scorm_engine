module ScormEngine
  module Api
    module Endpoints
      module Ping
        #
        # Get back a message indicating that the API is working.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__ping_get
        #
        # @returns [ScormEngine::Response]
        #
        def get_ping
          response = get("ping")
          Response.new(raw_response: response)
        end
      end
    end
  end
end
