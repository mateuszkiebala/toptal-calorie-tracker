module Foods
  class Create < Base::Auth

    PERMITTED_FOOD_FIELDS = [:name, :calorie_value, :taken_at].freeze

    FIELDS = [:food_attributes]
    attr_accessor *FIELDS

    validates :food_attributes, presence: true

    def call
      execute if self.valid?
      self
    end

    private

    def execute
      food = Food.new(prepare_data)
      food.save ? set_result(food, :created) : set_errors(food.errors)
    end

    def prepare_data
      @food_attributes.permit(PERMITTED_FOOD_FIELDS).merge(user: @current_user)
    end
  end
end
