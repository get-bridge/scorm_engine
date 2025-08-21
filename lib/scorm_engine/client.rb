require_relative "faraday/connection"
require_relative "faraday/request"

module ScormEngine
  class Client

    include Faraday::Connection
    include Faraday::Request
    include Api::Endpoints

    attr_reader :tenant

    def initialize(tenant:)
      @tenant = tenant
      @api_version = 2 # Default to API v2
    end

    def current_api_version
      @api_version || 2
    end
  end
end
