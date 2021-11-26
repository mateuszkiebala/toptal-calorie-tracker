FactoryBot.define do
  factory :food, class: Food do
    name { Faker::Name.unique.first_name }
    calorie_value { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    taken_at { Faker::Time.between(from: 7.days.ago, to: 7.days.from_now) }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    user { User.generate_random }
  end
end
