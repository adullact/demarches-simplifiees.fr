# frozen_string_literal: true

class RNFService
  include Dry::Monads[:result]

  CA_BUNDLE = Rails.root.join('config/certs/ac-racine-ministere-interieur-2018.pem').to_s

  def call(rnf_id:)
    result = API::Client.new.(url: "#{url}/#{rnf_id}", schema:, headers:, cainfo: CA_BUNDLE)
    case result
    in Success(body:)
      Success(body)
    in Failure(code:, error:) if code.in?(401..403)
      Failure(API::Client::Error[:unauthorized, code, false, error])
    # 400/404 errors are due to invalid RNF code
    # it cannot be fixed so we do not retry
    in Failure(code:, error:) if code.in?([400, 404])
      Failure(API::Client::Error[:bad_request, code, false, error])
    else
      result
    end
  end

  private

  def headers
    { Token: ENV['RNF_TOKEN'] }
  end

  def schema
    JSONSchemer.schema(Rails.root.join('app/schemas/rnf.json'))
  end

  def url
    "#{API_RNF_URL}/api/foundations"
  end
end
