class UserSerializer
  include JSONAPI::Serializer

  set_type :users
  attributes :username, :role, :calorie_limit, :money_limit
end