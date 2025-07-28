# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'devise'
require 'factory_bot_rails'
require 'pundit/rspec'
require 'simplecov'

include ActionDispatch::TestProcess::FixtureFile

SimpleCov.start 'rails' do
  add_filter '/spec/'
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include FactoryBot::Syntax::Methods

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.before(:suite) do
    # Set up Active Storage directory
    FileUtils.mkdir_p(Rails.root.join('tmp', 'storage'))
  end

  config.after(:suite) do
    # Clean up test files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end

  config.render_views = false

  config.use_transactional_fixtures = true

  config.include Devise::Test::IntegrationHelpers, type: :request

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
