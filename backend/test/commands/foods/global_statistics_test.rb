require 'test_helper'
require 'commands/base_test'

class Foods::GlobalStatisticsTest < BaseTest

  test 'success - no users' do
    # given
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::GlobalStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_equal(0, command.result.entries_count)
  end

  test 'success - one food' do
    # given
    food = create(:food, calorie_value: 123.4)
    options = { data_source: Food.all.to_a }

    # when
    command = Foods::GlobalStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_equal(1, command.result.entries_count)
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
    command = Foods::GlobalStatistics.new(options).call

    # then
    assert(command.success?)
    assert(command.result)
    assert_equal(:ok, command.status)
    assert_equal(5, command.result.entries_count)
  end
end
