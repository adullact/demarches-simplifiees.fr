module APIParticulier
  module Error
    class HttpError < ::StandardError
      def initialize(response)
        uri = URI.parse(response.effective_url)
        data = JSON.parse(response.body, symbolize_names: true)
        error = APIParticulier::Entities::Error.new(**data)

        msg = <<~TEXT
        url: #{uri.host}#{uri.path}
        HTTP error code: #{response.code}
        #{error}
        curl message: #{response.return_message}
        total time: #{response.total_time}
        connect time: #{response.connect_time}
        response headers: #{response.headers}
        TEXT

        super(msg)
      end
    end

    class TimedOut < HttpError; end
    class Unauthorized < HttpError; end
    class NotFound < HttpError; end
    class RequestFailed < HttpError; end
  end
end
