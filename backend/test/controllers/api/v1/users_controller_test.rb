require 'test_helper'
require 'controllers/authentication_test'

class UsersControllerTest < AuthenticationTest

  test 'fail my_profile - request must be authenticated' do
    # given
    @headers = {
      CONTENT_TYPE: "application/json"
    }

    # when, then
    assert_unauthenticated(:get, "/api/v1/my_profile")
  end

  test 'success my_profile' do
    # given, when
    get "/api/v1/my_profile", params: {}, headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = {
      "data" => {
        "id" => @user.id.to_s,
        "type" => "users",
        "attributes" => {
          "username" => @user.username,
          "role" => @user.role
        }
      }
    }
    assert_equal(expected, response)
  end
end
