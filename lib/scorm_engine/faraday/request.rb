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

      def api_v2(without_tenant: false)
        begin
          @api_version = 2
          @without_tenant = without_tenant

          yield
        ensure
          @api_version = 1
        end
      end

      private

      def request(method, path, options, body = nil)
        connection(version: @api_version).send(method) do |request|
          if @api_version == 2
            request.headers["engineTenantName"] = tenant unless @without_tenant
          else
            # "more" pagination urls are fully qualified
            path = "#{tenant}/#{path}" unless path =~ %r{\Ahttps?://}
          end

          options = coerce_options(options)

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
