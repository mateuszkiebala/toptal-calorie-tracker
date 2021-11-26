require 'test_helper'
require 'controllers/authentication_test'

module Admin
  class FoodsControllerTest < AuthenticationTest

    def setup
      @admin = create(:user, role: :admin)
      @auth_token = JsonWebToken.encode(user_id: @admin.id)
      @admin.update!(auth_token: @auth_token)

      @headers = {
        Authorization: "Bearer #{@auth_token}",
        CONTENT_TYPE: "application/json"
      }
    end

    test 'index - regular do not have access' do
      # given
      regular_user = create(:user, role: :regular)
      auth_token = JsonWebToken.encode(user_id: regular_user.id)
      regular_user.update!(auth_token: auth_token)

      @headers = {
        Authorization: "Bearer #{auth_token}",
        CONTENT_TYPE: "application/json"
      }

      create(:food, taken_at: '2021-11-21T00:00:00', user: regular_user)
      create(:food, taken_at: '2021-11-28T00:00:00', user: regular_user)

      get "/api/v1/admin/foods", headers: @headers

      # then
      assert_response :forbidden
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":403,"detail":"Not Authorised","source":nil,"title":"Forbidden","code":nil}]}.to_json
      assert_equal(expected, response.to_json)
    end

    test 'success index - check filtering and pagination' do
      # given
      user_1 = create(:user, role: :regular)
      user_2 = create(:user, role: :regular)
      create(:food, taken_at: '2021-11-21T00:00:00', user: user_2)
      food1 = create(:food, taken_at: '2021-11-22T00:00:00', user: user_2)
      food2 = create(:food, taken_at: '2021-11-23T00:00:00', user: user_2)
      food3 = create(:food, taken_at: '2021-11-24T00:00:00', user: user_1)
      create(:food, taken_at: '2021-11-25T00:00:00', user: @admin)
      create(:food, taken_at: '2021-11-26T00:00:00', user: user_1)
      create(:food, taken_at: '2021-11-27T00:00:00', user: user_1)
      create(:food, taken_at: '2021-11-28T00:00:00', user: user_1)

      get "/api/v1/admin/foods?page[number]=2&page[size]=3&filter[taken_at_gteq]='2021-11-22T00:00:00'&filter[taken_at_lteq]='2021-11-27T00:00:00'", headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
      assert_equal(expected, response["data"].to_json)

      expected_first_link = "http://www.example.com/api/v1/admin/foods?filter[taken_at_gteq]='2021-11-22T00:00:00'&filter[taken_at_lteq]='2021-11-27T00:00:00'&page[number]=1&page[size]=3"
      assert_equal(expected_first_link, response["links"]["first"])
    end

    test 'success index - fetch all data' do
      # given
      user_1 = create(:user, role: :regular)
      user_2 = create(:user, role: :regular)
      food1 = create(:food, taken_at: '2021-11-23T00:00:00', user: user_2)
      food2 = create(:food, taken_at: '2021-11-25T00:00:00', user: @admin)
      food3 = create(:food, taken_at: '2021-11-26T00:00:00', user: user_1)

      get "/api/v1/admin/foods", headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
      assert_equal(expected, response["data"].to_json)
    end
  end
end
