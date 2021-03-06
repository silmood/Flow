module Net
  class ResponseProxy
    def self.build_response(raw_body, response)
      new(raw_body, response).response
    end

    def initialize(raw_body, response)
      @raw_body = raw_body
      @response = response
    end

    def response
      Response.new({
        status_code: status_code,
        status_message: status_message,
        headers: headers,
        body: build_body
      })
    end

    private

    def status_message
      message = CFHTTPMessageCreateResponse(KCFAllocatorDefault,
        @response.statusCode, nil, KCFHTTPVersion1_1)
      CFHTTPMessageCopyResponseStatusLine(message)
    end

    def headers
      @response.allHeaderFields
    end

    def mime_type
      @response.MIMEType
    end

    def status_code
      @response.statusCode
    end

    def json?
      mime_type.match /application\/json/
    end

    def build_body
      if json? && @raw_body.length > 0
        return JSON.load(@raw_body.to_str)
      end

      @raw_body.to_str
    end
  end
end
