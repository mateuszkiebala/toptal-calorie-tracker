module Foods
  module Models
    class DailyStatisticsSerializer
      include JSONAPI::Serializer

      set_type :food_daily_statistics

      attribute :values do |object|
        object.values.map do |stat|
          {
            day: stat.day,
            calorie_sum: "%.2f" % stat.calorie_sum,
            price_sum: "%.2f" % stat.price_sum
          }
        end
      end
    end
  end
end
