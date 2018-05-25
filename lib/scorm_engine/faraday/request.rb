module ScormEngine
  module Faraday
    module Request
      def get(path, options = {})
        request(:get, path, options)
      end

      def post(path, options = {}, body = nil)
        request(:post, path, options, body)
      end

      def put(path, options = {}, body = nil)
        request(:put, path, options, body)
      end

      def delete(path, options = {})
        request(:delete, path, options)
      end

      private

      def request(method, path, options, body = nil)
        path = "#{tenant}/#{path}"

        options = coerce_options(options)

        connection.send(method) do |request|
          case method
          when :get, :delete
            request.url(path, options)
          when :post, :put
            if body.nil?
              body = options.dup
              options = {}
            end
            request.url(path, options)
            request.body = body unless body.empty?
          end
        end
      end

      def coerce_options(options = {})
        options.dup.each do |k, v|
          case k
          when :before, :since
            options[k] = v.iso8601 if v.respond_to?(:iso8601)
          end
        end
        options
      end
    end
  end
end
