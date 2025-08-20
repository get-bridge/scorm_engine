module ScormEngine
  module Faraday
         def request(method, path, options, body = nil)
        # Ensure api_version has a default value
        @api_version ||= 2
        
        connection(version: @api_version).send(method) do |request|
          if @api_version == 2
            request.headers["engineTenantName"] = tenant unless @without_tenant
          else
            path = "#{tenant}/#{path}" unless path =~ %r{\Ahttps?://} || path.start_with?(base_uri.path)
          endRequest
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

      # Initialize @api_version to 2 by default
      def initialize(*args)
        @api_version = 2
        super(*args) if defined?(super)
      end
      
      def api_v2(without_tenant: false)
        original_version = @api_version
        original_tenant = @without_tenant
        @api_version = 2
        @without_tenant = without_tenant

        yield
      ensure
        @api_version = original_version
        @without_tenant = original_tenant
      end

      private

      def request(method, path, options, body = nil)
        connection(version: @api_version).send(method) do |request|
          if @api_version == 2
            request.headers["engineTenantName"] = tenant unless @without_tenant
          else
            # "more" pagination urls are fully or relatively qualified
            path = "#{tenant}/#{path}" unless path =~ %r{\Ahttps?://} || path.start_with?(base_uri.path)
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
