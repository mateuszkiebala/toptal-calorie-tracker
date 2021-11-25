module Api
  module V1
    class UsersController < ApplicationController

      # GET /my_profile
      def my_profile
        data = { current_user: @current_user }
        handle_command(Users::MyProfile, data, :ok)
      end
    end
  end
end
