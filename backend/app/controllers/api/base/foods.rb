module Api
  module Base
    class Foods < ApplicationController

      class FoodsError < StandardError; end
      rescue_from FoodsError, with: :handle_bad_request

      protected

      def set_food_attributes
        data = @parsed_body['data']

        raise FoodsError.new("missing 'data' section in the body request") if data.blank?
        raise FoodsError.new("'type' doesn't match 'foods'") if data['type'] != 'foods'
        raise FoodsError.new("'attributes' section is missing") if data['attributes'].blank?
        @food_attributes = data['attributes']
      end
    end
  end
end
