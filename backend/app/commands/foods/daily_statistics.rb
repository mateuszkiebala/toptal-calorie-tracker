module Foods
  class DailyStatistics < Base::Structure

    FIELDS = [:data_source]
    attr_accessor *FIELDS

    protected

    def execute
      attributes = { values: daily_stats }
      cs = Models::DailyStatistics.new(attributes)
      cs.valid? ? set_result(cs, :ok) : set_errors(cs.errors)
    end

    def daily_stats
      @data_source.group_by { |food| food.taken_at.strftime('%Y-%m-%d') }.map do |day, foods|
        attrs = {
          day: day,
          calorie_sum: foods.inject(0.0) { |sum, food| sum + food.calorie_value },
          price_sum: foods.inject(0.0) { |sum, food| sum + food.price }
        }
        Models::DailyStatistics::Stat.new(attrs)
      end.sort_by(&:day)
    end
  end
end
