class FoodSerializer
  include JSONAPI::Serializer

  set_type :foods
  attributes :name
  belongs_to :user, serializer: OwnerSerializer

  attribute :calorie_value do |object|
    "%.2f" % object.calorie_value
  end

  attribute :price do |object|
    "%.2f" % object.price
  end

  attribute :taken_at do |object|
    object.taken_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
end