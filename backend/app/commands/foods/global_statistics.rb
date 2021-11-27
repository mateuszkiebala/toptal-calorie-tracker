module Foods
  class GlobalStatistics < Base::Structure

    FIELDS = [:data_source]
    attr_accessor *FIELDS

    protected

    def execute
      attributes = { entries_count: entries_count }
      fs = FoodGlobalStatistics.new(attributes)
      fs.valid? ? set_result(fs, :ok) : set_errors(fs.errors)
    end

    def entries_count
      @data_source.length
    end
  end
end
