module Api
  module V1
    class FoodsController < Api::Base::Foods
      before_action :set_food_attributes, only: [:create]

      # POST /api/v1/foods
      def create
        data = {
          food_attributes: @food_attributes,
          current_user: @current_user
        }
        handle_command(Foods::Create, data)
      end
    end
  end
end
