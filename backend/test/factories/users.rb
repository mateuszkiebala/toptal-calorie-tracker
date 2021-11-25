FactoryBot.define do
  factory :user, class: User do
    username { Faker::Name.unique.name }
    role { %i[regular admin][rand(2)] }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end
end
