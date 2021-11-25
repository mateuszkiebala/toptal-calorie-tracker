module Users
  class Profile < Common::Base

    def initialize(params)
      super(params)
    end

    def execute
      @result[:data] = @current_user.as_json(only: [:id, :username, :role])
      @succeeded = true
    end
  end
end
