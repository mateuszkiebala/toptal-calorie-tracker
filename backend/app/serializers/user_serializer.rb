class UserSerializer
  include JSONAPI::Serializer

  set_type :users
  attributes :username, :role
end