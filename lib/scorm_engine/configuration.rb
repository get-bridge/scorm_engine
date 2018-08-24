require "logger"

module ScormEngine
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    # http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html
    attr_accessor :protocol, :host, :path_prefix

    # http://rustici-docs.s3.amazonaws.com/engine/2017.1.x/Architecture-API.html#api-authentication
    attr_accessor :username, :password

    # defaults to /dev/null
    # https://github.com/lostisland/faraday/blob/5f1687abbe9eb1c96284b31e303e80f1a22acd09/lib/faraday/response/logger.rb#L7
    attr_accessor :logger, :log_options

    def initialize
      reset
    end

    def reset
      @protocol = ENV.fetch("SCORM_ENGINE_PROTOCOL", "https")
      @host = ENV["SCORM_ENGINE_HOST"]
      @path_prefix = ENV.fetch("SCORM_ENGINE_PATH_PREFIX", "/ScormEngineInterface/api/v1/")

      @username = ENV["SCORM_ENGINE_USERNAME"]
      @password = ENV["SCORM_ENGINE_PASSWORD"]

      @logger = ::Logger.new(ENV.fetch("SCORM_ENGINE_LOGFILE", "/dev/null"))

      @log_options = begin
                       JSON.parse(ENV.fetch("SCORM_ENGINE_LOG_OPTIONS"))
                     rescue KeyError, JSON::ParserError
                       { headers: false, bodies: false }
                     end
    end
  end
end
