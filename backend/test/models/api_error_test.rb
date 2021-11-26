require 'test_helper'

class ApiErrorTest < ActiveSupport::TestCase

  test 'serialization empty errors' do
    # given
    api_errors = []

    # when
    result = ApiError.serialize(api_errors)

    # then
    assert_nil(result)
  end

  test 'serialization nil errors' do
    # given
    api_errors = nil

    # when
    result = ApiError.serialize(api_errors)

    # then
    assert_nil(result)
  end

  test 'serialization empty details error' do
    # given
    api_errors = [ApiError.new(status: 401, detail: "", title: "Bad Request")]

    # when
    result = ApiError.serialize(api_errors)

    # then
    expected = {:errors=>[{:status=>401, :detail=>"", :source=>nil, :title=>"Bad Request", :code=>nil}]}
    assert_equal(expected, result)
  end

  test 'serialization multiple errors' do
    # given
    api_error_1 = ApiError.new(status: 401, detail: "Invalid parsing", title: "Bad Request")
    api_error_2 = ApiError.new(status: 402, detail: "Invalid parsing 2", title: "Bad Request")

    api_errors = [api_error_1, api_error_2]

    # when
    result = ApiError.serialize(api_errors)

    # then
    expected = { :errors => [{
                               :status=>401,
                               :detail=>"Invalid parsing",
                               :source=>nil,
                               :title=>"Bad Request",
                               :code=>nil
                             }, {
                               :status=>402,
                               :detail=>"Invalid parsing 2",
                               :source=>nil,
                               :title=>"Bad Request",
                               :code=>nil
                             }]}
    assert_equal(expected, result)
  end
end
