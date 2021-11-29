class UserSerializer
  include JSONAPI::Serializer

  set_type :users
  attributes :username, :role

  attribute :calorie_limit do |object|
    "%.2f" % object.calorie_limit
  end

  attribute :money_limit do |object|
    "%.2f" % object.money_limit
  end
end