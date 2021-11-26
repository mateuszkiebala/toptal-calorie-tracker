require 'test_helper'
require 'commands/base_test'

class Foods::CreateTest < BaseTest

  def execute_create(data)
    params = {
      current_user: @user,
      food_attributes: ActionController::Parameters.new(data)
    }
    Foods::Create.new(params).call
  end

  test 'user cannot be null' do
    assert_current_user_not_present(Foods::Create)
  end

  test 'fail no food_attributes' do
    # given
    options = {
      current_user: @user
    }

    # when
    command = Foods::Create.new(options).call

    # then
    assert_not(command.success?)
    assert_nil(command.result)
    assert_equal(["'Food attributes' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'fail food_attributes empty' do
    # given
    options = {}

    # when
    command = execute_create(options)

    # then
    assert_not(command.success?)
    assert_equal(["'Food attributes' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'fail food_attributes contains wrong data' do
    # given
    options = {
      name: "xx",
      calorie_value: -12
    }

    # when
    command = execute_create(options)

    # then
    assert_not(command.success?)
    expected = [
      "'name' is too short (minimum is 3 characters)",
      "'calorie_value' must be greater than or equal to 0",
      "'taken_at' can't be blank",
      "'taken_at' is not a datetime of format '%Y-%m-%dT%H:%M:%S'"
    ]

    assert_equal(expected, command.get_errors.full_messages)
    assert_equal(:unprocessable_entity, command.status)
  end

  test 'pass more attributes than permitted - skip them' do
    # given
    now = Time.now.utc
    options = {
      name: "test name",
      calorie_value: 14.23,
      taken_at: now,
      unknown_attr: "xxx"
    }

    # when
    command = execute_create(options)

    # then
    assert(command.success?)
    assert_equal(:created, command.status)
  end

  test 'success - no errors' do
    # given
    now = Time.now.utc
    options = {
      name: "test name",
      calorie_value: 14.23,
      taken_at: now
    }

    # when
    command = execute_create(options)

    # then
    assert(command.success?)
    expected = {
      :data => {
        :id => command.result.id.to_s,
        :type => :foods,
        :attributes => {
          :name => "test name",
          :calorie_value => "14.23",
          :taken_at => now.strftime("%Y-%m-%dT%H:%M:%S")
        },
        :relationships => {
          :user => {
            :data => {
              :id => @user.id.to_s,
              :type => :users
            }
          }
        }
      }
    }
    assert_equal(expected, FoodSerializer.new(command.result).serializable_hash)
    assert_equal(:created, command.status)
    assert_nil(command.get_errors)
  end
end
