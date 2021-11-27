module Foods
  class Update < Base::Auth

    PERMITTED_FOOD_FIELDS = [:name, :calorie_value, :taken_at, :price].freeze
    FIELDS = [:food, :food_attributes]
    attr_accessor *FIELDS
    validates :food_attributes, :food, presence: true

    protected

    def execute
      @food.update(prepare_attributes) ? set_result(nil, :no_content) : set_errors(@food.errors)
    end

    def prepare_attributes
      @food_attributes.permit(PERMITTED_FOOD_FIELDS)
    end
  end
end
