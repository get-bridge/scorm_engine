require_relative "endpoints/about"
require_relative "endpoints/courses"
require_relative "endpoints/courses/configuration"
require_relative "endpoints/courses/import"
require_relative "endpoints/ping"

module ScormEngine
  module Api
    module Endpoints
      include About
      include Courses
      include Courses::Configuration
      include Courses::Import
      include Ping
    end
  end
end
