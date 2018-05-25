require_relative "endpoints/about"
require_relative "endpoints/ping"

module ScormEngine
  module Api
    module Endpoints
      include About
      include Ping
    end
  end
end
