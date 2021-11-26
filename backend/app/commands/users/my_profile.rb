module Users
  class MyProfile < Base::Auth

    def initialize(params)
      super(params)
    end

    def execute
      set_result(@current_user)
    end
  end
end
