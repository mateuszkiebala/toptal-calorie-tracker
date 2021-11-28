require 'test_helper'
require 'commands/base_test'

class Foods::ShowTest < BaseTest

  test 'user cannot be null' do
    assert_current_user_not_present(Foods::Show)
  end

  test 'fail no food object' do
    # given
    attributes = {
      current_user: @user
    }

    # when
    command = Foods::Show.new(attributes).call

    # then
    assert_not(command.success?)
    assert_nil(command.result)
    assert_equal(["'Food' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'success' do
    # given
    food = create(:food)
    attributes = {
      food: food,
      current_user: @user
    }

    # when
    command = Foods::Show.new(attributes).call

    # then
    assert(command.success?)
    assert_equal(food.id, command.result.id)
    assert_equal(:ok, command.status)
  end
end
