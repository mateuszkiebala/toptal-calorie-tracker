module Foods
  class CalorieStatistics < Base::Structure

    FIELDS = [:data_source]
    attr_accessor *FIELDS

    protected

    def execute
      attributes = { daily: daily_calories }
      cs = Models::CalorieStatistics.new(attributes)
      cs.valid? ? set_result(cs, :ok) : set_errors(cs.errors)
    end

    def daily_calories
      @data_source.group_by { |food| food.taken_at.strftime('%Y-%m-%d') }.map do |day, foods|
        attrs = {
          day: day,
          sum: foods.inject(0.0) { |sum, food| sum + food.calorie_value }
        }
        Models::CalorieStatistics::Stat.new(attrs)
      end.sort_by(&:day)
    end
  end
end
