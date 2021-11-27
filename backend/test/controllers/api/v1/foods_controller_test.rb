require 'test_helper'
require 'controllers/authentication_test'

class FoodsControllerTest < AuthenticationTest

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
    expected = {"errors"=>[{"status"=>400, "detail"=>"'type' doesn't match 'foods'", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
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
    expected = {"errors"=>[{"status"=>400, "detail"=>"'type' doesn't match 'foods'", "source"=>nil, "title"=>"Bad Request", "code"=>nil}]}
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
end
