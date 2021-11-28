require 'test_helper'
require 'controllers/authentication_test'

class FoodsControllerTest < AuthenticationTest

  test 'fail show - request must be authenticated' do
    # given
    @headers = {
      CONTENT_TYPE: "application/json"
    }

    # when, then
    assert_unauthenticated(:get, "/api/v1/foods/12")
  end

  test 'fail show - food does not exist' do
    # given when
    get "/api/v1/foods/123321", headers: @headers

    # then
    assert_response :not_found
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>404, "detail"=>"food with id='123321' does not exist", "source"=>nil, "title"=>"Not Found", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'fail show - food does not belong to regular user' do
    # given
    user_regular = create(:user, role: :regular)
    auth_token = JsonWebToken.encode(user_id: user_regular.id)
    user_regular.update!(auth_token: auth_token)
    headers = {
      Authorization: "Bearer #{auth_token}",
      CONTENT_TYPE: "application/json"
    }

    user_stranger = create(:user)
    food = create(:food, user: user_stranger)

    # when
    get "/api/v1/foods/#{food.id}", headers: headers

    # then
    assert_response :forbidden
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>403, "detail"=>"Not Authorised", "source"=>nil, "title"=>"Forbidden", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'success show - food does not belong to user but it is admin' do
    # given
    user_admin = create(:user, role: :admin)
    auth_token = JsonWebToken.encode(user_id: user_admin.id)
    user_admin.update!(auth_token: auth_token)
    headers = {
      Authorization: "Bearer #{auth_token}",
      CONTENT_TYPE: "application/json"
    }

    user_stranger = create(:user)
    food = create(:food, user: user_stranger)

    # when
    get "/api/v1/foods/#{food.id}", headers: headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    assert_equal(food.id.to_s, response["data"]["id"])
  end

  test 'success show - same owner - user regular' do
    # given
    food = create(:food, user: @user)

    # when
    get "/api/v1/foods/#{food.id}", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = {
      "id": food.id.to_s,
      "type": "foods",
      "attributes": {
        "name": food.name,
        "calorie_value": food.calorie_value.to_s('F'),
        "price": "0.0",
        "taken_at": food.taken_at.strftime("%Y-%m-%dT%H:%M:%S")
      }
    }
    assert_equal(expected.to_json, response["data"].except("relationships").to_json)
  end

  test 'fail create - request must be authenticated' do
    # given
    @headers = {
      CONTENT_TYPE: "application/json"
    }

    # when, then
    assert_unauthenticated(:post, "/api/v1/foods")
  end

  test 'fail create - no data' do
    # given
    now = Time.now.utc
    params = {
      type: "foods",
      attributes: {
        name: "test food name",
        calorie_value: 123.8388,
        taken_at: now.iso8601
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :bad_request
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>400, "detail"=>"missing 'data' section in the body request", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'fail create - no type' do
    # given
    now = Time.now.utc
    params = {
      data: {
        attributes: {
          name: "test food name",
          calorie_value: 123.8388,
          taken_at: now.iso8601
        }
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :bad_request
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>400, "detail"=>"'type'='' doesn't match 'foods'", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'fail create - wrong type' do
    # given
    now = Time.now.utc
    params = {
      data: {
        type: "invalid",
        attributes: {
          name: "test food name",
          calorie_value: 123.8388,
          taken_at: now.iso8601
        }
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :bad_request
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>400, "detail"=>"'type'='invalid' doesn't match 'foods'", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'fail create - no attributes' do
    # given
    params = {
      data: {
        type: "foods"
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :bad_request
    response = JSON.parse(@response.body)
    expected = {"errors"=>[{"status"=>400, "detail"=>"'attributes' section is missing", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
    assert_equal(expected, response)
  end

  test 'fail create - invalid attributes' do
    # given
    now = Time.now.utc
    params = {
      data: {
        type: "foods",
        attributes: {
          name: "te",
          calorie_value: -123.8388,
          taken_at: "xx"
        }
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :unprocessable_entity
    response = JSON.parse(@response.body)
    expected = { "errors"=>[{
                              "status"=>"422",
                              "source"=>{"pointer"=>"/data/attributes/name"},
                              "title"=>"Unprocessable Entity",
                              "detail"=>"'name' is too short (minimum is 3 characters)",
                              "code"=>"too_short"
                            }, {
                              "status"=>"422",
                              "source"=>{"pointer"=>"/data/attributes/calorie_value"},
                              "title"=>"Unprocessable Entity",
                              "detail"=>"'calorie_value' must be greater than or equal to 0",
                              "code"=>"greater_than_or_equal_to"
                            }, {
                              "status"=>"422",
                              "source"=>{"pointer"=>"/data/attributes/taken_at"},
                              "title"=>"Unprocessable Entity",
                              "detail"=>"'taken_at' can't be blank",
                              "code"=>"blank"
                            }, {
                              "status"=>"422",
                              "source"=>{"pointer"=>"/data/attributes/taken_at"},
                              "title"=>"Unprocessable Entity",
                              "detail"=>"'taken_at' is not a datetime of format '%Y-%m-%dT%H:%M:%S'",
                              "code"=>"invalid_format"
                            }
    ]}
    assert_equal(expected, response)
  end

  test 'success create' do
    # given
    now = Time.now.utc
    params = {
      data: {
        type: "foods",
        attributes: {
          name: "test food name",
          calorie_value: 123.8388,
          taken_at: now.iso8601,
          price: "12344"
        }
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :created
    response = JSON.parse(@response.body)
    expected = {
      "type" => "foods",
      "attributes" => {
        "name" => "test food name",
        "calorie_value" => "123.84",
        "taken_at" => now.strftime("%Y-%m-%dT%H:%M:%S"),
        "price" => "12344.0"
      },
      "relationships" => {
        "user" => {
          "data" => {
            "id" => @user.id.to_s,
            "type" => "users"
          }
        }
      }
    }
    assert_equal(expected, response["data"].except("id"))
  end

  test 'fail index - request must be authenticated' do
    # given
    @headers = {
      CONTENT_TYPE: "application/json"
    }

    # when, then
    assert_unauthenticated(:get, "/api/v1/foods")
  end

  test 'index - invalid page number - use default number' do
    # given
    create(:food, taken_at: '2021-11-21T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-22T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-23T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-24T00:00:00', user: @user)
    food1 = create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    food3 = create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    get "/api/v1/foods?page[number]=x&page[size]=3", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)
  end

  test 'index - invalid page size - use default size' do
    # given
    food1 = create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    food3 = create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    get "/api/v1/foods?page[number]=1&page[size]=x**x", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)
  end

  test 'success index - check filtering' do
    # given
    create(:food, taken_at: '2021-11-21T00:00:00', user: @user)
    food1 = create(:food, taken_at: '2021-11-22T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-23T00:00:00', user: @user)
    food3 = create(:food, taken_at: '2021-11-24T00:00:00', user: @user)
    food4 = create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    food5 = create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    # when
    get "/api/v1/foods?&filter[taken_at_gteq]='2021-11-22T00:00:00'&filter[taken_at_lteq]='2021-11-26T00:00:00'", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food5, food4, food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)
  end

  test 'success index - check pagination' do
    # given
    create(:food, taken_at: '2021-11-21T00:00:00', user: @user)
    food1 = create(:food, taken_at: '2021-11-22T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-23T00:00:00', user: @user)
    food3 = create(:food, taken_at: '2021-11-24T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    get "/api/v1/foods?page[number]=2&page[size]=3", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)

    expected_next_link = 'http://www.example.com/api/v1/foods?page[number]=3&page[size]=3'
    assert_equal(expected_next_link, response["links"]["next"])
  end

  test 'success index - check filtering and pagination' do
    # given
    create(:food, taken_at: '2021-11-21T00:00:00', user: @user)
    food1 = create(:food, taken_at: '2021-11-22T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-23T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-24T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    get "/api/v1/foods?page[number]=2&page[size]=3&filter[taken_at_gteq]='2021-11-22T00:00:00'&filter[taken_at_lteq]='2021-11-26T00:00:00'", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)
    assert_equal(5, response["meta"]["records"])
  end

  test 'success index - fetch only your data' do
    # given
    user_2 = create(:user)
    create(:food, taken_at: '2021-11-21T00:00:00', user: user_2)
    create(:food, taken_at: '2021-11-22T00:00:00', user: user_2)
    create(:food, taken_at: '2021-11-23T00:00:00', user: user_2)
    create(:food, taken_at: '2021-11-24T00:00:00', user: user_2)
    food1 = create(:food, taken_at: '2021-11-25T00:00:00', user: @user)
    food2 = create(:food, taken_at: '2021-11-26T00:00:00', user: @user)
    food3 = create(:food, taken_at: '2021-11-27T00:00:00', user: @user)

    get "/api/v1/foods", headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    expected = [food3, food2, food1].map {|food| FoodSerializer.new(food).serializable_hash[:data]}.to_json
    assert_equal(expected, response["data"].to_json)
  end

  test 'fail daily_statistics - request must be authenticated' do
    # given
    @headers = {
      CONTENT_TYPE: "application/json"
    }

    # when, then
    assert_unauthenticated(:get, "/api/v1/foods/daily_statistics")
  end

  test 'daily_statistics success - empty' do
    # given, when
    get "/api/v1/foods/daily_statistics", params: {}, headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    assert_equal("food_daily_statistics", response["data"]["type"])
    assert_empty(response["data"]["attributes"]["values"])
  end

  test 'daily_statistics success - no filter' do
    # given
    user1 = create(:user)
    user2 = create(:user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1200.99, calorie_value: 12, user: @user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1300.99, calorie_value: 13, user: user1)
    create(:food, taken_at: "2021-11-24 11:29:00", price: 1400.99, calorie_value: 15, user: @user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1500.99, calorie_value: 14, user: user2)

    # when
    get "/api/v1/foods/daily_statistics", params: {}, headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    assert_equal("food_daily_statistics", response["data"]["type"])
    expected = {"values"=>[{"day"=>"2021-11-23", "calorie_sum"=>"12.0", "price_sum"=>"1200.99"},
                          {"day"=>"2021-11-24", "calorie_sum"=>"15.0", "price_sum"=>"1400.99"}]}
    assert_equal(expected, response["data"]["attributes"])
  end

  test 'daily_statistics success - with filters - one day' do
    # given
    user1 = create(:user)
    user2 = create(:user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1200.99, calorie_value: 12, user: @user)
    create(:food, taken_at: "2021-11-23 23:59:59", price: 1300.99, calorie_value: 99, user: @user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1400.99, calorie_value: 13, user: user1)
    create(:food, taken_at: "2021-11-24 11:29:00", price: 1500.99, calorie_value: 15, user: @user)
    create(:food, taken_at: "2021-11-23 11:29:00", price: 1600.99, calorie_value: 14, user: user2)

    # when
    get "/api/v1/foods/daily_statistics?filter[taken_at_gteq]='2021-11-23T00:00:00'&filter[taken_at_lteq]='2021-11-23T23:59:59'", params: {}, headers: @headers

    # then
    assert_response :ok
    response = JSON.parse(@response.body)
    assert_equal("food_daily_statistics", response["data"]["type"])
    expected = {"values"=>[{"day"=>"2021-11-23", "calorie_sum"=>"111.0", "price_sum"=>"2501.98"}]}
    assert_equal(expected, response["data"]["attributes"])
  end
end
