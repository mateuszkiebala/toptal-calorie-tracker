require 'test_helper'
require 'commands/base_test'

class Foods::CalorieStatisticsTest < BaseTest

  test 'success - no food' do
    # given
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::CalorieStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_empty(command.result.daily)
  end

  test 'success - one food' do
    # given
    food = create(:food, calorie_value: 123.4, taken_at: "2021-11-23 19:23:23")
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::CalorieStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_equal([{:day=>'2021-11-23', :sum=>food.calorie_value}].to_json, command.result.daily.to_json)
  end

  test 'success - complex' do
    # given
    create(:food, taken_at: "2021-11-21 19:23:23", calorie_value: 9000)
    create(:food, taken_at: "2021-11-21 19:23:23", calorie_value: 9000.5)
    create(:food, taken_at: "2021-11-22 19:23:23", calorie_value: 17)
    create(:food, taken_at: "2021-11-23 19:23:23", calorie_value: 15)
    create(:food, taken_at: "2021-11-23 19:23:23", calorie_value: 3000)

    options = { data_source: Food.all.to_a }

    # when
    command = Foods::CalorieStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    expected = [{ :day=>"2021-11-21", :sum=>"18000.5" },
                { :day=>"2021-11-22", :sum=>"17.0" },
                { :day=>"2021-11-23", :sum=>"3015.0" }]
    assert_equal(expected.to_json, command.result.daily.to_json)
  end
end
