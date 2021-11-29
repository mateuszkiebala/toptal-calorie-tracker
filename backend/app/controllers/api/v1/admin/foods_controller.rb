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

        # GET /api/v1/admin/foods/user_statistics
        def user_statistics
          pagination_data_source = User.order(id: :asc)
          links = jsonapi_pagination(pagination_data_source)
          meta = jsonapi_pagination_meta(pagination_data_source)
          offset, limit, _ = jsonapi_pagination_params

          jsonapi_paginate(pagination_data_source) do |paginated|
            users_to_fetch = paginated.pluck(:id)
            if users_to_fetch.blank?
              handle_command(Foods::UserStatistics, { data_source: [], limit: limit, offset: offset }, { links: links, meta: meta })
            else
              filter_data_source = Food.where(user_id: users_to_fetch).order(taken_at: :desc)
              allowed = [:taken_at]
              jsonapi_filter(filter_data_source, allowed) do |filtered|
                command_data = {
                  data_source: filtered.result,
                  limit: limit,
                  offset: offset
                }
                handle_command(Foods::UserStatistics, command_data, { links: links, meta: meta })
              end
            end
          end
        end

        # GET /api/v1/admin/foods/global_statistics
        def global_statistics
          filter_data_source = Food.all.order(taken_at: :desc)
          allowed = [:taken_at]
          jsonapi_filter(filter_data_source, allowed) do |filtered|
            handle_command(Foods::GlobalStatistics, { data_source: filtered.result })
          end
        end
      end
    end
  end
end
