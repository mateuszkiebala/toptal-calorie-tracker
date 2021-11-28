require 'test_helper'

class FoodTest < ActiveSupport::TestCase
  def setup
    super
     @user = create(:user)
  end

  def assert_validation_errors(expected, result, field)
    assert_equal(1, result.length)
    assert_equal(Set.new(expected), Set.new(result[field]))
  end

  def formatted_now
    @formatted_now ||= Time.now.iso8601(3)
  end

  test 'name is missing' do
    # given
    data = {
      calorie_value: 12,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can't be blank", "is too short (minimum is 3 characters)", "can contain only letters, digits and spaces"], food.errors.messages, :name)
  end

  test 'name too short' do
    # given
    data = {
      name: "a",
      calorie_value: 12,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["is too short (minimum is 3 characters)"], food.errors.messages, :name)
  end

  test 'name too long' do
    # given
    data = {
      name: "a" * 200,
      calorie_value: 12,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["is too long (maximum is 100 characters)"], food.errors.messages, :name)
  end

  test 'name does not match format' do
    # given
    data = {
      name: "a%%&aaaDELETE",
      calorie_value: 12,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can contain only letters, digits and spaces"], food.errors.messages, :name)
  end

  test 'name is in proper format' do
    # given
    data = {
      name: "Id 56s 9as",
      calorie_value: 12,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert(food.save)
    assert_empty(food.errors.messages)
  end

  test 'calorie_value is missing' do
    # given
    data = {
      name: "aaa",
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can't be blank", "is not a number"], food.errors.messages, :calorie_value)
  end

  test 'calorie_value negative' do
    # given
    data = {
      name: "aaa",
      calorie_value: -0.77,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["must be greater than or equal to 0"], food.errors.messages, :calorie_value)
  end

  test 'calorie_value too big' do
    # given
    data = {
      name: "aaa",
      calorie_value: 10 ** 20,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["must be less than or equal to 10000"], food.errors.messages, :calorie_value)
  end

  test 'calorie_value is a text' do
    # given
    data = {
      name: "aaa",
      calorie_value: "DELETE SOME ROW&&%%",
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["is not a number"], food.errors.messages, :calorie_value)
  end

  test 'calorie_value too many decimals' do
    # given
    data = {
      name: "aaa",
      calorie_value: 5.67897,
      taken_at: formatted_now,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert(food.save)
    assert_empty(food.errors.messages)
    assert_equal(5.68, food.calorie_value)
  end

  test 'taken_at is a random text' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: "DELETE SOME ROW&&%%",
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can't be blank", "is not a datetime of format '%Y-%m-%dT%H:%M:%S'"], food.errors.messages, :taken_at)
  end

  test 'taken_at is a number' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: 1234,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can't be blank", "is not a datetime of format '%Y-%m-%dT%H:%M:%S'"], food.errors.messages, :taken_at)
  end

  test 'taken_at is empty' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      user_id: @user.id
    }

    # when
    food = Food.new(data)

    # then
    assert_not(food.save)
    assert_validation_errors(["can't be blank", "is not a datetime of format '%Y-%m-%dT%H:%M:%S'"], food.errors.messages, :taken_at)
  end

  test 'price negative' do
    # given
    food = create(:food)

    # when
    food.price = -123.3

    # then
    assert_not(food.save)
    assert_equal(["'price' must be greater than or equal to 0"], food.errors.full_messages)
  end

  test 'price is a text' do
    # given
    food = create(:food)

    # when
    food.price = "test hack"

    # then
    assert_not(food.save)
    assert_equal(["'price' is not a number"], food.errors.full_messages)
  end

  test 'price default is 0' do
    # given, when
    food = create(:food)

    # then
    assert_equal(0, food.price)
  end

  test 'unique food per user - separate users' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: formatted_now,
      user_id: @user.id
    }
    Food.create!(data)
    user_2 = create(:user)

    # when
    food_2 = Food.new(data.merge(user_id: user_2.id))

    # then
    assert(food_2.save)
    assert_empty(food_2.errors.messages)
  end

  test 'same food per user' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: formatted_now,
      user_id: @user.id
    }
    Food.create!(data)

    # when
    food_2 = Food.new(data.merge(calorie_value: 444))

    # then
    assert(food_2.save)
    assert(Food.find_by(id: food_2.id))
  end

  test 'delete food - do not delete user' do
    # given
    data = {
      name: "aaa",
      calorie_value: 123,
      taken_at: formatted_now,
      user_id: @user.id
    }
    food = Food.create!(data)

    # when, then
    assert(food.destroy)
    assert_nil(Food.find_by(id: food.id))
    assert(User.find_by(id: @user.id))
  end
end
