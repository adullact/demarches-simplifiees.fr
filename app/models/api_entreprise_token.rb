class APIEntrepriseToken
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def roles
    return [] if token.blank?

    Array(decoded_token["roles"])
  end

  def expired?
    return false if token.blank? || !decoded_token.key?("exp")

    Time.zone.now.to_i >= decoded_token["exp"]
  end

  def role?(role)
    roles.include?(role)
  end

  private

  def decoded_token
    @decoded_token ||= {}
    @decoded_token[token] ||= JWT.decode(token, nil, false)[0]
  end
end
