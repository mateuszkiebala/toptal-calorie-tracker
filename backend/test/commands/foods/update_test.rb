require 'test_helper'
require 'commands/base_test'

class Foods::UpdateTest < BaseTest

  def execute_update(food, data)
    params = {
      current_user: @user,
      food: food,
      food_attributes: ActionController::Parameters.new(data)
    }
    Foods::Update.new(params).call
  end

  test 'user cannot be null' do
    assert_current_user_not_present(Foods::Update)
  end

  test 'fail no food_attributes' do
    # given
    attributes = {
      current_user: @user
    }

    # when
    command = Foods::Update.new(attributes).call

    # then
    assert_not(command.success?)
    assert_nil(command.result)
    assert_equal(["'Food attributes' can't be blank", "'Food' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'fail food_attributes empty' do
    # given
    food = create(:food, user: @user)
    attributes = {}

    # when
    command = execute_update(food, attributes)

    # then
    assert_not(command.success?)
    assert_equal(["'Food attributes' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'fail food_attributes contains wrong data' do
    # given
    food = create(:food, user: @user)
    attributes = {
      name: "xx",
      calorie_value: -12
    }

    # when
    command = execute_update(food, attributes)

    # then
    assert_not(command.success?)
    expected = [
      "'name' is too short (minimum is 3 characters)",
      "'calorie_value' must be greater than or equal to 0"
    ]

    assert_equal(expected, command.get_errors.full_messages)
    assert_equal(:unprocessable_entity, command.status)
  end

  test 'pass more attributes than permitted - skip them' do
    # given
    now = Time.now.utc
    food = create(:food, user: @user)
    attributes = {
      name: "test name",
      calorie_value: 14.23,
      taken_at: now,
      unknown_attr: "xxx"
    }

    # when
    command = execute_update(food, attributes)

    # then
    assert(command.success?)
    assert_equal(:no_content, command.status)
    assert_nil(command.result)
  end

  test 'success - no errors' do
    # given
    now = Time.now.utc
    food = create(:food, name: "Test name", calorie_value: 123, taken_at: 10.days.ago, user: @user)
    attributes = {
      name: "new test name",
      taken_at: now
    }

    # when
    command = execute_update(food, attributes)

    # then
    assert(command.success?)
    assert_equal(:no_content, command.status)
    assert_nil(command.result)
    assert_nil(command.get_errors)

    food.reload
    assert_equal(attributes[:name], food.name)
    assert_equal(attributes[:taken_at].strftime('%Y-%m-%d %H:%M:%S'), food.taken_at.strftime('%Y-%m-%d %H:%M:%S'))
    assert_equal(123, food.calorie_value)
  end
end
