module Foods
  class UserStatistics < Base::Structure

    FIELDS = [:data_source]
    attr_accessor *FIELDS

    protected

    def execute
      attributes = { average_calories: average_calories }
      fs = Models::UserStatistics.new(attributes)
      fs.valid? ? set_result(fs, :ok) : set_errors(fs.errors)
    end

    def average_calories
      @data_source.group_by(&:user_id).map do |user_id, foods|
        attrs = {
          user_id: user_id,
          value: (foods.inject(0.0) { |sum, food| sum + food.calorie_value }) / foods.length
        }
        Models::UserStatistics::Stat.new(attrs)
      end.sort_by(&:user_id)
    end
  end
end
