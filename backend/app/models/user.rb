require 'faker'

class User < ApplicationRecord
  enum role: %i[regular admin].freeze

  def self.generate_random
    username = Faker::Name.unique.name
    role = %i[regular admin][rand(2)]

    user = create!({ username: username, role: role })
    user.update!(auth_token: JsonWebToken.encode(user_id: user.id))
    user
  end
end
