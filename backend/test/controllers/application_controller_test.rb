require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'not_found' do
    # given, when
    post '/some_random_path'

    # then
    assert_response 404
    expected = {"errors"=>[{"source"=>nil, "details"=>["Endpoint not found"]}]}
    assert_equal(expected, JSON.parse(@response.body))
  end
end