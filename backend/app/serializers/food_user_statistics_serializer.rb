class FoodUserStatisticsSerializer
  include JSONAPI::Serializer

  set_type :food_user_statistics

  attribute :average_calories do |object|
    object.average_calories.map do |stat|
      {
        user_id: stat.user_id,
        value: stat.value.to_s('F')
      }
    end
  end
end
