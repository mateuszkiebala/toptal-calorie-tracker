class Food < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates_format_of :name, with: /\A[a-zA-Z0-9\s]+\z/i, message: "can contain only letters, digits and spaces"
  validates :calorie_value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10000 }
  validates :price, presence: false, numericality: { greater_than_or_equal_to: 0 }
  validates :taken_at, presence: true, datetime: true

  def self.generate_random
    user_ids = User.all.pluck(:id)
    user_id = user_ids[rand(user_ids.length)]
    name = Faker::Lorem.unique.characters(number: 6)
    calorie_value = Faker::Number.decimal(l_digits: 3, r_digits: 2)
    price = Faker::Number.decimal(l_digits: 3, r_digits: 2)
    taken_at = Faker::Time.between(from: 30.days.ago, to: Time.now.utc)
    food = create!({ name: name, calorie_value: calorie_value, price: price, taken_at: taken_at, user_id: user_id })
    food
  end
end
