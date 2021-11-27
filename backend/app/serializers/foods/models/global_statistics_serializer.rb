module Foods
  module Models
    class GlobalStatisticsSerializer
      include JSONAPI::Serializer

      set_type :food_global_statistics
      attributes :entries_count
    end
  end
end
