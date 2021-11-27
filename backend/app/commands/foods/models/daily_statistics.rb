module Foods
  module Models
    class DailyStatistics < Statistics
      attr_accessor :values

      class Stat
        include ActiveModel::Model
        attr_accessor :day, :calorie_sum, :price_sum
      end
    end
  end
end
