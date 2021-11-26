module Foods
  class Destroy < Base::Auth

    FIELDS = [:food]
    attr_accessor *FIELDS
    validates :food, presence: true

    protected

    def execute
      @food.destroy ? set_result(nil, :no_content) : set_errors(@food.errors)
    end
  end
end
