class User < ApplicationRecord
  enum role: %i[regular admin].freeze
end
