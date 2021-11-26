class Food < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }, uniqueness: { scope: :user }
  validates_format_of :name, with: /\A[a-zA-Z0-9\s]+\z/i, message: "can contain only letters, digits and spaces"
  validates :calorie_value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10000 }
  validates :taken_at, presence: true, datetime: true
end
