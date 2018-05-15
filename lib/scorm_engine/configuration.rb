require "logger"

module ScormEngine
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    # http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html
    attr_accessor :base_url
    
    # http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/Architecture-API.html#api-authentication
    attr_accessor :username, :password

    # defaults to /dev/null
    attr_accessor :logger

    def initialize
      @logger = ::Logger.new("/dev/null")
    end
  end
end
