module Api
  module V1
    module Admin
      class FoodsController < Api::Base::Foods
        before_action :authorise_admin_access
        before_action :set_food, only: [:update, :destroy]
        before_action :set_food_attributes, only: [:update]

        # GET /api/v1/admin/foods
        def index
          data_source = Food.order(taken_at: :desc)
          allowed = [:taken_at]
          render_jsonapi_index(data_source, allowed)
        end

        # PATCH /api/v1/admin/foods/:id
        def update
          data = {
            food: @food,
            food_attributes: @food_attributes,
            current_user: @current_user
          }
          handle_command(Foods::Update, data)
        end

        # DELETE /api/v1/admin/foods/:id
        def destroy
          data = {
            food: @food,
            current_user: @current_user
          }
          handle_command(Foods::Destroy, data)
        end
      end
    end
  end
end
