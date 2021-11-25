class AuthenticateApiRequest < BasicStructure

  FIELDS = [:headers].freeze
  attr_accessor *FIELDS

  def initialize(headers = {})
    super({})
    @headers = headers
  end

  def execute
    unless decoded_auth_token.present?
      add_error(msg: 'Invalid token', code: 401)
      return
    end

    user = User.find_by(id: decoded_auth_token[:user_id], auth_token: auth_token)
    if user.present?
      @succeeded = true
      @result = user
    else
      add_error(msg: 'Invalid token', code: 401)
    end
  end

  private

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(auth_token)
  end

  def auth_token
    @auth_token ||= http_auth_header
  end

  def http_auth_header
    if @headers['Authorization'].present?
      return @headers['Authorization'].split(' ').last
    else
      add_error(msg: 'Missing authentication token', code: 401)
    end
    nil
  end
end
