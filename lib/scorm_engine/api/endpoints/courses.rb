module ScormEngine
  module Api
    module Endpoints
      module Courses

        #
        # Get the list of courses
        #
        # @param [Hash] options
        #
        # @option options [DateTime] :since 
        #   Only courses updated since the specified ISO 8601 TimeStamp
        #   (inclusive) are included.  If a time zone is not specified, the
        #   server's time zone will be used.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__courses_get
        def courses(options = {})
          response = get("courses", options)

          result = if response.success?
                     response.body["courses"].map do |course|
                       ScormEngine::Models::Course.new_from_api(course)
                     end
                   else
                     []
                   end

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
