require 'test_helper'
require 'commands/base_test'

class Foods::DestroyTest < BaseTest

  test 'user cannot be null' do
    assert_current_user_not_present(Foods::Destroy)
  end

  test 'fail no food' do
    # given
    options = {
      current_user: @user
    }

    # when
    command = Foods::Destroy.new(options).call

    # then
    assert_not(command.success?)
    assert_nil(command.result)
    assert_equal(["'Food' can't be blank"], command.errors.full_messages)
    assert_equal(:bad_request, command.status)
  end

  test 'success' do
    # given
    food = create(:food)

    # when
    command = Foods::Destroy.new(food: food, current_user: @user).call

    # then
    assert(command.success?)
    assert_equal(:no_content, command.status)
    assert_nil(command.result)
    assert_nil(command.get_errors)
    assert_nil(Food.find_by(id: food.id))
  end
end
