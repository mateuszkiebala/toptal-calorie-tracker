require 'test_helper'

class AuthenticateApiRequestTest < ActionController::TestCase

  def setup
    @user = create(:user)
  end

  test 'valid_token' do
    # given
    @user.auth_token = JsonWebToken.encode({user_id: @user.id})
    @user.save!

    headers = {
      "Authorization" => "Bearer #{@user.auth_token}"
    }

    # when
    result = AuthenticateApiRequest.new(headers).call

    # then
    assert(result)
  end

  test 'invalid_token' do
    # given
    @user.auth_token = nil
    @user.save!

    headers = {
      "Authorization" => "Bearer weak_token_1234"
    }

    # when
    result = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(result)
  end

  test 'invalid_token mismatch user' do
    # given
    @user.auth_token = JsonWebToken.encode({user_id: nil})
    @user.save!

    headers = {
      "Authorization" => "Bearer #{@user.auth_token}"
    }

    # when
    result = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(result)
  end

  test 'missing_auth_header' do
    # given
    headers = {}

    # when
    result = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(result)
  end

  test 'empty_token' do
    # given
    headers = {
      "Authorization" => ""
    }

    # when
    result = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(result)
  end
end
