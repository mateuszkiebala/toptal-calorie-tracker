module Foods
  module Models
    class UserStatistics < Statistics
      attr_accessor :average_calories

      class Stat
        include ActiveModel::Model
        attr_accessor :user_id, :value
      end
    end
  end
end
