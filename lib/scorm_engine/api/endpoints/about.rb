module ScormEngine
  module Api
    module Endpoints
      module About
        #
        # Get back the version and platform of the running instance of Engine
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__about_get
        #
        # @return [ScormEngine::Response]
        #
        def get_about
          response = get("about")
          result = OpenStruct.new(response.body)
          Response.new(raw_response: response, result: result)
        end

        #
        # Gets the number of users across all tenants.
        #
        # @see http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html#tenant__about_userCount_get
        #
        # @param [Hash] options
        #
        # @option options [DateTime] :before 
        #   Only userCount updated before the specified time (inclusive) are included. 
        #   If a time zone is not specified, the server's time zone will be used.
        #
        # @option options [DateTime] :since 
        #   Only userCount updated since the specified time (inclusive) are included.
        #   If a time zone is not specified, the server's time zone will be used.
        #
        # @return [ScormEngine::Response]
        #
        def get_about_user_count(options = {})
          response = get("about/userCount", options)

          result = OpenStruct.new
          result.total = response.body["combinedTenants"]["total"]
          result.dispatched = response.body["combinedTenants"]["dispatched"]
          result.non_dispatched = response.body["combinedTenants"]["nonDispatched"]
          result.by_tenant = {}
          response.body["byTenant"].each do |tenant|
            result.by_tenant[tenant["tenantName"]] = OpenStruct.new(
              total: tenant["total"],
              dispatched: tenant["dispatched"],
              non_dispatched: tenant["nonDispatched"]
            )
          end

          Response.new(raw_response: response, result: result)
        end
      end
    end
  end
end
