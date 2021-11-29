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
      assert_unauthorised('get', "/api/v1/admin/foods")
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
      assert_equal(6, response["meta"]["records"])
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

    test 'update fail - unauthorised user' do
      assert_unauthorised('patch', '/api/v1/admin/foods/12')
    end

    test 'update fail - food does not exist' do
      # given
      params = {
        data: {
          type: "foods",
          attributes: {
            name: "new super name"
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/7777788", params: params.to_json, headers: @headers

      # then
      assert_response :not_found
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":404,"detail":"food with id='7777788' does not exist","source":nil,"title":"Not Found","code":nil}]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'update fail - type does not match' do
      # given
      food = create(:food)
      params = {
        data: {
          type: "invalid",
          attributes: {
            name: "new super name"
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :bad_request
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":400,"detail":"'type'='invalid' doesn't match 'foods'","source":nil,"title":"Bad Request","code":nil}]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'update fail - invalid attributes' do
      # given
      food = create(:food)
      params = {
        data: {
          type: "foods",
          attributes: {
            taken_at: 123
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :unprocessable_entity
      response = JSON.parse(@response.body)
      expected = {
        "errors":[{
                    "status":"422",
                    "source":{"pointer":"/data/attributes/taken_at"},
                    "title":"Unprocessable Entity",
                    "detail":"'taken_at' can't be blank",
                    "code":"blank"
                  },{
                    "status":"422",
                    "source":{"pointer":"/data/attributes/taken_at"},
                    "title":"Unprocessable Entity",
                    "detail":"'taken_at' is not a datetime of format '%Y-%m-%dT%H:%M:%S'",
                    "code":"invalid_format"}
        ]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'update fail - empty attributes' do
      # given
      food = create(:food)
      params = {
        data: {
          type: "foods",
          attributes: {}
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :bad_request
      response = JSON.parse(@response.body)
      expected = {"errors"=>[{"status"=>400, "detail"=>"'attributes' section is missing", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'update fail - missing id' do
      # given
      params = {}

      # when
      patch "/api/v1/admin/foods/", params: params.to_json, headers: @headers

      # then
      assert_response :not_found
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":404,"detail":"Endpoint not found","source":nil,"title":"Not Found","code":nil}]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'update success' do
      # given
      food = create(:food, name: "old", calorie_value: 123)
      params = {
        data: {
          type: "foods",
          attributes: {
            calorie_value: 8982.23
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :no_content
      assert_empty(@response.body)
      food.reload
      assert_equal('8982.23', food.calorie_value.to_s('F'))
      assert_equal("old", food.name)
      assert_equal('0.0', food.price.to_s('F'))
    end

    test 'update success - only price' do
      # given
      food = create(:food, name: "old", calorie_value: 123)
      params = {
        data: {
          type: "foods",
          attributes: {
            price: 128.99
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :no_content
      assert_empty(@response.body)
      food.reload
      assert_equal('128.99', food.price.to_s('F'))
      assert_equal("old", food.name)
      assert_equal('123.0', food.calorie_value.to_s('F'))
    end

    test 'delete fail - unauthorised regular user' do
      assert_unauthorised('delete', '/api/v1/admin/foods/123')
    end

    test 'delete fail - food not found' do
      # given, when
      delete "/api/v1/admin/foods/", params: {}, headers: @headers

      # then
      assert_response :not_found
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":404,"detail":"Endpoint not found","source":nil,"title":"Not Found","code":nil}]}
      assert_equal(expected.to_json, response.to_json)
    end

    test 'delete success' do
      # given
      food = create(:food)

      # when
      delete "/api/v1/admin/foods/#{food.id}", params: {}, headers: @headers

      # then
      assert_response :no_content
      assert_empty(@response.body)
      assert_nil(Food.find_by(id: food.id))
    end

    test 'user_statistics not authorise' do
      assert_unauthorised('get', '/api/v1/admin/foods/user_statistics')
    end

    test 'user_statistics success - empty' do
      # given when
      get "/api/v1/admin/foods/user_statistics?page[number]=2&page[size]=3", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_user_statistics", response["data"]["type"])
      expected_stats = {"average_calories"=>[]}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    test 'user statistics success - without filters' do
      # given
      user1 = create(:user)
      user2 = create(:user)
      food1 = create(:food, calorie_value: 12, user: user1)
      food2 = create(:food, calorie_value: 15, user: user2)

      # when
      get "/api/v1/admin/foods/user_statistics", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_user_statistics", response["data"]["type"])
      expected_stats = {"average_calories"=>[{"user_id"=>@admin.id, "value"=>"0.00"},
                                             {"user_id"=>user1.id, "value"=>"12.00"},
                                             {"user_id"=>user2.id, "value"=>"15.00"}]}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    test 'user_statistics success - pagination with filters' do
      # given
      user0 = create(:user, username: "0")
      user1 = create(:user, username: "1")
      user2 = create(:user, username: "2")
      user3 = create(:user, username: "3")
      user4 = create(:user, username: "4")
      user5 = create(:user, username: "5")
      create(:food, user: user0, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user1, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user2, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user3, calorie_value: 15, taken_at: "2021-11-20 00:00:00" )
      create(:food, user: user3, calorie_value: 17, taken_at: "2021-11-21 00:00:00" )
      create(:food, user: user3, calorie_value: 20, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 500, taken_at: "2021-11-21 00:00:00" )
      create(:food, user: user4, calorie_value: 21, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 160, taken_at: "2021-11-25 00:00:00" )
      create(:food, user: user5, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )

      # when
      get "/api/v1/admin/foods/user_statistics?page[number]=2&page[size]=3&filter[taken_at_gteq]='2021-11-21T00:00:00'&filter[taken_at_lteq]='2021-11-22T00:00:00'", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_user_statistics", response["data"]["type"])
      expected_stats = {
        "average_calories"=>[{"user_id"=>user2.id, "value"=>"0.00"},
                             {"user_id"=>user3.id, "value"=>"18.50"},
                             {"user_id"=>user4.id, "value"=>"180.25"}]}
      assert_equal(expected_stats, response["data"]["attributes"])

      expected_next_link = "http://www.example.com/api/v1/admin/foods/user_statistics?filter[taken_at_gteq]='2021-11-21T00:00:00'&filter[taken_at_lteq]='2021-11-22T00:00:00'&page[number]=3&page[size]=3"
      assert_equal(expected_next_link, response["links"]["next"])
      assert_equal(User.all.count, response["meta"]["records"])
    end

    test 'global_statistics not authorise' do
      assert_unauthorised('get', '/api/v1/admin/foods/global_statistics')
    end

    test 'global_statistics success - empty' do
      # given, when
      get "/api/v1/admin/foods/global_statistics", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_global_statistics", response["data"]["type"])
      expected_stats = {"entries_count"=>0}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    test 'global_statistics success - without filters' do
      # given
      create(:food, calorie_value: 12)
      create(:food, calorie_value: 15)

      # when
      get "/api/v1/admin/foods/global_statistics", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_global_statistics", response["data"]["type"])
      expected_stats = {"entries_count"=>2}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    test 'global_statistics success - filtered - do not use strange filters' do
      # given
      user1 = create(:user, username: "1")
      user2 = create(:user, username: "2")
      user3 = create(:user, username: "3")
      create(:food, user: user1, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user2, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user3, calorie_value: 15, taken_at: "2021-11-20 00:00:00" )
      create(:food, user: user3, calorie_value: 17, taken_at: "2021-11-21 00:00:00" )
      create(:food, user: user3, calorie_value: 20, taken_at: "2021-11-22 00:00:00" )

      # when
      get "/api/v1/admin/foods/global_statistics?filter[calorie_value_gteq]=13&filter[calorie_value_lteq]=17", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_global_statistics", response["data"]["type"])
      expected_stats = {"entries_count"=>5}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    test 'global_statistics success - filtered' do
      # given
      user1 = create(:user, username: "1")
      user2 = create(:user, username: "2")
      user3 = create(:user, username: "3")
      user4 = create(:user, username: "4")
      user5 = create(:user, username: "5")
      create(:food, user: user1, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user2, calorie_value: 12, taken_at: "2021-11-20 00:00:00")
      create(:food, user: user3, calorie_value: 15, taken_at: "2021-11-20 00:00:00" )
      create(:food, user: user3, calorie_value: 17, taken_at: "2021-11-21 00:00:00" )
      create(:food, user: user3, calorie_value: 20, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 500, taken_at: "2021-11-21 00:00:00" )
      create(:food, user: user4, calorie_value: 21, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )
      create(:food, user: user4, calorie_value: 160, taken_at: "2021-11-25 00:00:00" )
      create(:food, user: user5, calorie_value: 100, taken_at: "2021-11-22 00:00:00" )

      # when
      get "/api/v1/admin/foods/global_statistics?filter[taken_at_gteq]='2021-11-21T00:00:00'&filter[taken_at_lteq]='2021-11-22T00:00:00'", params: {}, headers: @headers

      # then
      assert_response :ok
      response = JSON.parse(@response.body)
      assert_equal("food_global_statistics", response["data"]["type"])
      expected_stats = {"entries_count"=>7}
      assert_equal(expected_stats, response["data"]["attributes"])
    end

    def assert_unauthorised(request_type, path)
      # given
      regular_user = create(:user, role: :regular)
      auth_token = JsonWebToken.encode(user_id: regular_user.id)
      regular_user.update!(auth_token: auth_token)

      headers = {
        Authorization: "Bearer #{auth_token}",
        CONTENT_TYPE: "application/json"
      }

      # when
      self.send(request_type, path, headers: headers)

      # then
      assert_response :forbidden
      response = JSON.parse(@response.body)
      expected = {"errors":[{"status":403,"detail":"Not Authorised","source":nil,"title":"Forbidden","code":nil}]}.to_json
      assert_equal(expected, response.to_json)
    end
  end
end
