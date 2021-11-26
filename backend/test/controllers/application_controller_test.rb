require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'not_found' do
    # given, when
    post '/some_random_path'

    # then
    assert_response 404
    expected = {"errors"=>[{"status"=>404, "detail"=>"Endpoint not found", "source"=>nil, "title"=>"Not Found", "code"=>nil}]}
    assert_equal(expected, JSON.parse(@response.body))
  end
end