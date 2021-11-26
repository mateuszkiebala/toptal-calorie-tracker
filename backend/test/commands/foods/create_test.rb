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
    expected = { :errors => [{:source => :food_attributes, :details => ["can't be blank"]}] }
    assert_equal(expected, command.get_errors)
    assert_equal(:bad_request, command.status)
  end

  test 'fail food_attributes empty' do
    # given
    options = {}

    # when
    command = execute_create(options)

    # then
    assert_not(command.success?)
    expected = {:errors=>[{:source=>:food_attributes, :details=>["can't be blank"]}]}
    assert_equal(expected, command.get_errors)
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
    expected = {
      :errors => [{
                    :source => :name,
                    :details => ["is too short (minimum is 3 characters)"]
                  }, {
                    :source => :calorie_value,
                    :details => ["must be greater than or equal to 0"]
                  }, {
                    :source => :taken_at,
                    :details => ["can't be blank", "is not a datetime of format '%Y-%m-%dT%H:%M:%S'"]
                  }]
    }
    assert_equal(expected, command.get_errors)
    assert_equal(:bad_request, command.status)
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
        :id => command.result[:data][:id],
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
    assert_equal(expected, command.result)
    assert_equal(:created, command.status)
    assert_nil(command.get_errors)
  end
end
