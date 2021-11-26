module Foods
  class Create < Base::Auth

    FOOD_FIELDS = [:name, :calorie_value, :taken_at].freeze
    PERMITTED_FIELDS = FOOD_FIELDS.freeze

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
      if food.save
        @result = FoodSerializer.new(food).serializable_hash
        @status = :created
        @succeeded = true
      else
        append_model_errors(food)
      end
    end

    def prepare_data
      @food_attributes.permit(PERMITTED_FIELDS).merge(user: @current_user)
    end
  end
end
