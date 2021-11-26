require 'test_helper'

class BaseTest < ActionController::TestCase

  def setup
    @user = create(:user)
  end

  def assert_current_user_not_present(command)
    # given
    data = {
      current_user: nil
    }

    # when
    assert_raises ArgumentError do
      command.new(data).call
    end
  end
end
