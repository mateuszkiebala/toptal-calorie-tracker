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
      expected = {"errors":[{"status":400,"detail":"'type' doesn't match 'foods'","source":nil,"title":"Bad Request","code":nil}]}
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
      new_calorie = 8982.23
      params = {
        data: {
          type: "foods",
          attributes: {
            calorie_value: new_calorie
          }
        }
      }

      # when
      patch "/api/v1/admin/foods/#{food.id}", params: params.to_json, headers: @headers

      # then
      assert_response :no_content
      assert_empty(@response.body)
      food.reload
      assert_equal(BigDecimal(new_calorie, 10).to_s('F'), food.calorie_value.to_s('F'))
      assert_equal("old", food.name)
    end

    test 'delete fail - unauthorised regular user' do
      assert_unauthenticated('delete', '/api/v1/admin/foods/123')
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

    def assert_unauthenticated(request_type, path)
      # given when
      self.send(request_type, path)

      # then
      assert_response :unauthorized
      response = JSON.parse(@response.body)
      expected = {"errors"=>[{"status"=>401, "detail"=>"Not Authenticated", "source"=>nil, "title"=>"Unauthorized", "code"=>nil}]}
      assert_equal(expected, response)
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
