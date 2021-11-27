class FoodStatistics
  include ActiveModel::Model

  attr_accessor :id

  def initialize(attributes = nil)
    super
    @id = SecureRandom.hex(5)
  end
end
