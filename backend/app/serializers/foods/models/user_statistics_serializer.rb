module Foods
  module Models
    class UserStatisticsSerializer
      include JSONAPI::Serializer

      set_type :food_user_statistics

      attribute :average_calories do |object|
        object.average_calories.map do |stat|
          {
            user_id: stat.user_id,
            value: "%.2f" % stat.value
          }
        end
      end
    end
  end
end
