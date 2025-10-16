require_relative "faraday/connection"
require_relative "faraday/request"

module ScormEngine
  class Client

    include Faraday::Connection
    include Faraday::Request
    include Api::Endpoints

    attr_reader :tenant, :tenant_creator

    def initialize(tenant:, tenant_creator: nil)
      @tenant = tenant
      @tenant_creator = tenant_creator
      @api_version = 2 # Default to API v2
    end

    def current_api_version
      @api_version || 2
    end
  end
end
