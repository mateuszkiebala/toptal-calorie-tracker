require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'generate_random - id encoded into token' do
    # given, when
    user = User.generate_random

    # then
    assert(User.find_by(id: user&.id))
    user&.reload
    token_data = JsonWebToken.decode(user&.auth_token)
    assert_equal(user&.id, token_data[:user_id])
  end
end
