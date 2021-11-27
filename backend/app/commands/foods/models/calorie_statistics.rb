module Foods
  module Models
    class CalorieStatistics < Statistics
      attr_accessor :daily

      class Stat
        include ActiveModel::Model
        attr_accessor :day, :sum
      end
    end
  end
end
