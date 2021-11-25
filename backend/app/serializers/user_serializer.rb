class UserSerializer
  include JSONAPI::Serializer

  attributes :username, :role
end