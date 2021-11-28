module Users
  class MyProfile < Base::Auth

    def execute
      set_result(@current_user)
    end
  end
end
