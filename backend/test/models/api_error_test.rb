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
    api_errors = [ApiError.new(source: "test_key", details: [])]

    # when
    result = ApiError.serialize(api_errors)

    # then
    assert_nil(result)
  end

  test 'serialization single error' do
    # given
    api_errors = [ApiError.new(source: "test_key", details: %w[d1 d2])]

    # when
    result = ApiError.serialize(api_errors)

    # then
    expected = { :errors => [{ :source => "test_key", :details => %w[d1 d2] }] }
    assert_equal(expected, result)
  end

  test 'serialization multiple errors' do
    # given
    api_error_1 = ApiError.new(source: "test_key_1", details: %w[d1 d2])
    api_error_2 = ApiError.new(source: "test_key_2", details: %w[d3])
    api_error_3 = ApiError.new(source: "test_key_3", details: %w[])
    api_error_4 = ApiError.new(source: "test_key_3", details: %w[d3 d8])
    api_error_5 = ApiError.new(source: "test_key_4", details: %w[])

    api_errors = [api_error_1, api_error_2, api_error_3, api_error_4, api_error_5]

    # when
    result = ApiError.serialize(api_errors)

    # then
    expected = { :errors => [{
                               :source => "test_key_1",
                               :details => %w[d1 d2]
                             }, {
                               :source => "test_key_2",
                               :details => %w[d3]
                             }, {
                               :source => "test_key_3",
                               :details => %w[d3 d8]
                             }]}
    assert_equal(expected, result)
  end
end
