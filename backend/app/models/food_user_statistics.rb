class FoodUserStatistics < FoodStatistics
  attr_accessor :average_calories

  class Stat
    include ActiveModel::Model
    attr_accessor :user_id, :value
  end
end
