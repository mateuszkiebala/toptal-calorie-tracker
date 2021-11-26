module Api
  module V1
    class UsersController < ApplicationController

      # GET /api/v1/my_profile
      def my_profile
        data = { current_user: @current_user }
        handle_command(Users::MyProfile, data)
      end
    end
  end
end
