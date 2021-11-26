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
    assert_equal(:accepted, command.status)
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
    expected = {:errors=>[{:source=>"auth_token", :details=>["Invalid token"]}]}
    assert_equal(expected, command.get_errors)
    assert_equal(:unauthorized, command.status)
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
    assert_equal(:unauthorized, command.status)
    expected = { :errors => [{:source => "auth_token", :details => ["Invalid token"]}] }
    assert_equal(expected, command.get_errors)
  end

  test 'missing_auth_header' do
    # given
    headers = {}

    # when
    command = AuthenticateApiRequest.new(headers).call

    # then
    assert_not(command.success?)
    assert_equal(:unauthorized, command.status)
    expected = {:errors=>[{:source=>"auth_token", :details=>["Missing authentication token", "Invalid token"]}]}
    assert_equal(expected, command.get_errors)
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
    assert_equal(:unauthorized, command.status)
    expected = {:errors=>[{:source=>"auth_token", :details=>["Missing authentication token", "Invalid token"]}]}
    assert_equal(expected, command.get_errors)
  end
end
