module ScormEngine
  class Response
    attr_reader :raw_response, :result

    delegate :success?, :status, :body, to: :raw_response

    def initialize(raw_response:, result: nil)
      @raw_response = raw_response
      @result = result
    end

    def results
      result.is_a?(Enumerator) ? result : Array(result)
    end

    def message
      raw_response.body["message"] if raw_response.body.is_a?(Hash)
    end

    def detailed_error_info
      return "Success" if success?

      error_info = {
        status: status,
        message: message,
        body: raw_response.body,
        headers: raw_response.headers.to_hash
      }

      error_info.inspect
    end
  end
end
