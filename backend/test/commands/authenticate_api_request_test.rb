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
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert(command.success?)
    assert(command.result)
  end

  test 'invalid_token' do
    # given
    @user.auth_token = nil
    @user.save!

    headers = {
      "Authorization" => "Bearer weak_token_1234"
    }

    # when
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(command.success?)
    assert_equal(Set.new(["Invalid token"]), Set.new(command.get_errors[:messages]))
  end

  test 'invalid_token mismatch user' do
    # given
    @user.auth_token = JsonWebToken.encode({user_id: nil})
    @user.save!

    headers = {
      "Authorization" => "Bearer #{@user.auth_token}"
    }

    # when
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(command.success?)
    assert_equal(Set.new(["Invalid token"]), Set.new(command.get_errors[:messages]))
  end

  test 'missing_auth_header' do
    # given
    headers = {}

    # when
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(command.success?)
    assert_equal(Set.new(["Missing authentication token", "Invalid token"]), Set.new(command.get_errors[:messages]))
  end

  test 'empty_token' do
    # given
    headers = {
      "Authorization" => ""
    }

    # when
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(command.success?)
    assert_equal(Set.new(["Missing authentication token", "Invalid token"]), Set.new(command.get_errors[:messages]))
  end
end
