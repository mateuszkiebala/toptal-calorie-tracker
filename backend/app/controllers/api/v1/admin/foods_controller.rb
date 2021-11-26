module Api
  module V1
    module Admin
      class FoodsController < Api::Base::Foods
        before_action :authorise_admin_access

        # GET /api/v1/admin/foods
        def index
          data_source = Food.order(taken_at: :desc)
          allowed = [:taken_at]
          render_jsonapi_index(data_source, allowed)
        end
      end
    end
  end
end
