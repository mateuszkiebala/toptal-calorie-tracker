class FoodGlobalStatisticsSerializer
  include JSONAPI::Serializer

  set_type :food_global_statistics
  attributes :entries_count
end
