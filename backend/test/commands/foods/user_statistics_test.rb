require 'test_helper'
require 'commands/base_test'

class Foods::UserStatisticsTest < BaseTest

  test 'success - no users' do
    # given
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::UserStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_empty(command.result.average_calories)
  end

  test 'success - one food' do
    # given
    food = create(:food, calorie_value: 123.4)
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::UserStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_equal([{:user_id=>food.user_id, :value=>food.calorie_value}].to_json, command.result.average_calories.to_json)
  end

  test 'success - complex' do
    # given
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    create(:food, calorie_value: 9000, user: user1)
    create(:food, calorie_value: 9000.5, user: user1)
    create(:food, calorie_value: 17, user: user2)
    create(:food, calorie_value: 15, user: user2)
    create(:food, calorie_value: 3000, user: user3)

    options = { data_source: Food.all.to_a }

    # when
    command = Foods::UserStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    expected = [{ :user_id=>user1.id, :value=>"9000.25" },
                { :user_id=>user2.id, :value=>"16.0" },
                { :user_id=>user3.id, :value=>"3000.0" }]
    assert_equal(expected.to_json, command.result.average_calories.to_json)
  end
end
