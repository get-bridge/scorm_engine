require "faraday"
require "faraday_middleware"

module ScormEngine
  module Faraday
    module Connection

      def base_uri(version: 1)
        uri = URI("")
        uri.scheme = ScormEngine.configuration.protocol
        uri.host = ScormEngine.configuration.host

        uri.path = if version == 2
                     ScormEngine.configuration.v2_path_prefix
                   else
                     ScormEngine.configuration.path_prefix
                   end

        URI(uri.to_s) # convert URI::Generic to URI:HTTPS
      end

      private

      def connection(version: 1)
        @connection ||= ::Faraday.new(url: base_uri(version: version).to_s) do |faraday|
          faraday.headers["User-Agent"] = "ScormEngine Ruby Gem #{ScormEngine::VERSION}"

          faraday.basic_auth(ScormEngine.configuration.username, ScormEngine.configuration.password)

          faraday.request :multipart
          faraday.request :json

          faraday.response :json, content_type: /\bjson$/
          faraday.response :logger, ScormEngine.configuration.logger, ScormEngine.configuration.log_options

          faraday.adapter ::Faraday.default_adapter
        end
      end
    end
  end
end
