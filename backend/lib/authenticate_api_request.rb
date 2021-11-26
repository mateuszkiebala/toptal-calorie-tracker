class AuthenticateApiRequest

  def initialize(headers = {})
    @headers = headers
  end

  def call
    return unless decoded_auth_token.present?
    User.find_by(id: decoded_auth_token[:user_id], auth_token: auth_token)
  end

  private

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(auth_token)
  end

  def auth_token
    @auth_token ||= http_auth_header
  end

  def http_auth_header
    @headers['Authorization'].present? ? @headers['Authorization'].split(' ').last : nil
  end
end
