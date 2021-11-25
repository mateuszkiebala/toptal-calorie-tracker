module Users
  class MyProfile < Base::Auth

    def initialize(params)
      super(params)
    end

    def execute
      @result = UserSerializer.new(@current_user).serializable_hash
      @succeeded = true
    end
  end
end
