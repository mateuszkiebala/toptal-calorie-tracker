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

  test 'destroy food on user deletion' do
    # given
    user = User.generate_random
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'),
      user_id: user.id
    }
    food_1 = Food.create!(data)
    food_2 = Food.create!(data.merge(name: "test 2"))

    # when, then
    assert(user.destroy)
    assert_nil(User.find_by(id: user.id))
    assert_empty(Food.where(id: [food_1.id, food_2.id]))
  end
end
