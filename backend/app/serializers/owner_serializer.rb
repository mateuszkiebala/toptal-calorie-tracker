class OwnerSerializer
  include JSONAPI::Serializer

  set_type :users
  attributes :id, :username
end