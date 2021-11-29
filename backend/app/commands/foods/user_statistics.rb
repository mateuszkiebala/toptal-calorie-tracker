module Foods
  class UserStatistics < Base::Structure

    FIELDS = [:data_source, :offset, :limit]
    attr_accessor *FIELDS
    validates :offset, :limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    protected

    def execute
      attributes = { average_calories: average_calories }
      fs = Models::UserStatistics.new(attributes)
      fs.valid? ? set_result(fs, :ok) : set_errors(fs.errors)
    end

    def average_calories
      users_with_stats = {}
      @data_source.group_by(&:user_id).map do |user_id, foods|
        users_with_stats[user_id] = (foods.inject(0.0) { |sum, food| sum + food.calorie_value }) / foods.length
      end

      fetch_all_users_in_range.pluck(:id).map do |user_id|
        attrs = {
          user_id: user_id,
          value: users_with_stats[user_id] || 0.0
        }
        Models::UserStatistics::Stat.new(attrs)
      end.sort_by(&:user_id)
    end

    def fetch_all_users_in_range
      User.all.order(id: :asc).offset(@offset).limit(@limit)
    end
  end
end
