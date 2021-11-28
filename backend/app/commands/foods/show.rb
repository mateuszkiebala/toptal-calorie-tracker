module Foods
  class Show < Base::Auth
    attr_accessor :food
    validates :food, presence: true

    def execute
      set_result(@food)
    end
  end
end
