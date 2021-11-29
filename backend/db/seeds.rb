unless Rails.env.production?
  10.times.each { |_| User.generate_random(:regular) }
  2.times.each { |_| User.generate_random(:admin) }

  500.times.each { |_| Food.generate_random }
end
