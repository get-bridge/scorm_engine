module ScormEngine
  class Response
    attr_reader :raw_response, :result

    def initialize(raw_response:, result: nil)
      @raw_response = raw_response
      @result = result
    end

    def results
      result.is_a?(Enumerator) ? result : Array(result)
    end

    def success?
      raw_response.success?
    end

    def status
      raw_response.status
    end

    def message
      raw_response.body["message"] if raw_response.body.is_a?(Hash)
    end
  end
end
