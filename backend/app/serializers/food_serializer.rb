class FoodSerializer
  include JSONAPI::Serializer

  set_type :foods
  attributes :name
  belongs_to :user, serializer: OwnerSerializer

  attribute :calorie_value do |object|
    object.calorie_value.to_s('F')
  end

  attribute :taken_at do |object|
    object.taken_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
end