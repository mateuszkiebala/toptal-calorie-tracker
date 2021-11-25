class AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @auth_token = JsonWebToken.encode(user_id: @user.id)
    @user.update!(auth_token: @auth_token)

    @headers = {
      Authorization: "Bearer #{@auth_token}",
      CONTENT_TYPE: "application/json"
    }
  end

  def assert_unauthorized(request_type, path)
    # given when
    self.send(request_type, path)

    # then
    assert_response :unauthorized
    response = JSON.parse(@response.body)
    expected = { "error" => { "messages" => "Not Authorized" }}
    assert_equal(expected, response)
  end
end
