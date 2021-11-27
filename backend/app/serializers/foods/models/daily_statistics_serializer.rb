module Foods
  module Models
    class DailyStatisticsSerializer
      include JSONAPI::Serializer

      set_type :food_daily_statistics

      attribute :values do |object|
        object.values.map do |stat|
          {
            day: stat.day,
            calorie_sum: stat.calorie_sum.to_s('F'),
            price_sum: stat.price_sum.to_s('F')
          }
        end
      end
    end
  end
end
