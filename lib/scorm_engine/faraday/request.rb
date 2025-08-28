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
        @api_version = 2
        @without_tenant = without_tenant

        yield
      ensure
        @api_version = nil  # Reset to default
      end

      def api_v1
        @api_version = 1

        yield
      ensure
        @api_version = nil  # Reset to default
      end

      private

      def request(method, path, options, body = nil)
        api_version = @api_version || current_api_version
        @retry_attempted = false unless defined?(@retry_attempted)

        begin
          make_request(method, path, options, body, api_version)
        rescue => e
          # Check if this is a tenant not found error and we have a tenant creator
          if should_retry_with_tenant_creation?(e) && @tenant_creator && !@retry_attempted
            @retry_attempted = true
            
            begin
              @tenant_creator.call(@tenant)
              # Retry the original request
              make_request(method, path, options, body, api_version)
            rescue => retry_error
              # If tenant creation or retry fails, raise the original error
              raise e
            end
          else
            raise e
          end
        end
      end

      def make_request(method, path, options, body, api_version)
        connection(version: api_version).send(method) do |request|
          if api_version == 2
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

      def should_retry_with_tenant_creation?(error)
        return false unless error.respond_to?(:response)
        
        response = error.response
        return false unless response
        
        # Check for 400 status with tenant not found message
        if response.status == 400
          body = response.body
          body_text = body.to_s
          return body_text.include?("is not a valid tenant name")
        end
        
        false
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
