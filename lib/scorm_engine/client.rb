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
    end
  end
end
