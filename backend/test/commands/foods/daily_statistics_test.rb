require 'test_helper'
require 'commands/base_test'

class Foods::DailyStatisticsTest < BaseTest

  test 'success - no food' do
    # given
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::DailyStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_empty(command.result.values)
  end

  test 'success - one food' do
    # given
    food = create(:food, calorie_value: 123.4, price: 182.99, taken_at: "2021-11-23 19:23:23")
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::DailyStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    expected = [{:day=>'2021-11-23', :calorie_sum=>food.calorie_value, :price_sum=>food.price}].to_json
    assert_equal(expected, command.result.values.to_json)
  end

  test 'success - complex' do
    # given
    create(:food, taken_at: "2021-11-21 19:23:23", price: 124.0, calorie_value: 9000)
    create(:food, taken_at: "2021-11-21 19:23:23", calorie_value: 9000.5)
    create(:food, taken_at: "2021-11-22 19:23:23", price: 14, calorie_value: 17)
    create(:food, taken_at: "2021-11-23 19:23:23", price: 99999, calorie_value: 15)
    create(:food, taken_at: "2021-11-23 19:23:23", price: 100, calorie_value: 3000)

    options = { data_source: Food.all.to_a }

    # when
    command = Foods::DailyStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    expected = [{ :day=>"2021-11-21", :calorie_sum=>"18000.5", :price_sum=>"124.0" },
                { :day=>"2021-11-22", :calorie_sum=>"17.0", :price_sum=>"14.0" },
                { :day=>"2021-11-23", :calorie_sum=>"3015.0", :price_sum=>"100099.0" }]
    assert_equal(expected.to_json, command.result.values.to_json)
  end
end
