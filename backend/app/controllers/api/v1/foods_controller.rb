module Api
  module V1
    class FoodsController < Api::Base::Foods
      before_action :set_food_attributes, only: [:create]

      # GET /api/v1/foods
      def index
        data_source = Food.where(user: @current_user).order(taken_at: :desc)
        allowed = [:taken_at]
        render_jsonapi_index(data_source, allowed)
      end

      # POST /api/v1/foods
      def create
        data = {
          food_attributes: @food_attributes,
          current_user: @current_user
        }
        handle_command(Foods::Create, data)
      end

      # GET /api/v1/foods/daily_statistics
      def daily_statistics
        filter_data_source = Food.where(user_id: @current_user.id).order(taken_at: :desc)
        allowed = [:taken_at]
        jsonapi_filter(filter_data_source, allowed) do |filtered|
          handle_command(Foods::DailyStatistics, { data_source: filtered.result })
        end
      end
    end
  end
end
