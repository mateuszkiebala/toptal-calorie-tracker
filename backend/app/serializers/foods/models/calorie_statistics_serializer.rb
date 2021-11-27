module Foods
  module Models
    class CalorieStatisticsSerializer
      include JSONAPI::Serializer

      set_type :food_calorie_statistics

      attribute :daily do |object|
        object.daily.map do |stat|
          {
            day: stat.day,
            sum: stat.sum.to_s('F')
          }
        end
      end
    end
  end
end
