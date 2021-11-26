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
    expected = {"errors"=>[{"source"=>nil, "details"=>["missing 'data' section in the body request"]}]}
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
    expected = {"errors"=>[{"source"=>nil, "details"=>["'type' doesn't match 'foods'"]}]}
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
    expected = {"errors"=>[{"source"=>nil, "details"=>["'type' doesn't match 'foods'"]}]}
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
    expected = {"errors"=>[{"source"=>nil, "details"=>["'attributes' section is missing"]}]}
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
          taken_at: now.iso8601
        }
      }
    }
    # when
    post "/api/v1/foods", params: params.to_json, headers: @headers

    # then
    assert_response :bad_request
    response = JSON.parse(@response.body)
    expected = {
      "errors"=>[{
                   "source"=>"name",
                   "details"=>["is too short (minimum is 3 characters)"]
                 }, {
                   "source"=>"calorie_value",
                   "details"=>["must be greater than or equal to 0"]}
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
          taken_at: now.iso8601
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
        "taken_at" => now.strftime("%Y-%m-%dT%H:%M:%S")
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
end
