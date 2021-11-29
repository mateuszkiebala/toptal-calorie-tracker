ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter('/app/channels')
  add_filter('/app/jobs')
  add_filter('/app/mailers')
  add_filter('/app/validators')
end

require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  parallelize(workers: 1)

  include FactoryBot::Syntax::Methods
  ActiveRecord::Migration.check_pending!

  fixtures :all
end
