module Foods
  module Models
    class Statistics
      include ActiveModel::Model
      attr_accessor :id

      def initialize(attributes = nil)
        super
        @id = SecureRandom.hex(5)
      end
    end
  end
end
