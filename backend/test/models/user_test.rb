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

  test 'invalid calorie_limit' do
    # given
    user = User.generate_random

    # when
    user.calorie_limit = -0.9

    # then
    assert_not(user.save)
    assert_equal(["'calorie_limit' must be greater than or equal to 0"], user.errors.full_messages)
  end

  test 'calorie_limit default' do
    # given, when
    user = create(:user)

    # then
    assert_equal(2100.0, user.calorie_limit)
  end

  test 'invalid money_limit' do
    # given
    user = User.generate_random

    user.money_limit = -0.9
    # when

    # then
    assert_not(user.save)
    assert_equal(["'money_limit' must be greater than or equal to 0"], user.errors.full_messages)
  end

  test 'money_limit default' do
    # given, when
    user = create(:user)

    # then
    assert_equal(1000.0, user.money_limit)
  end
end
