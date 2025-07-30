# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'devise'
require 'factory_bot_rails'
require 'pundit/rspec'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.before(:suite) do
    ActiveStorage::Current.url_options = {
      host: 'localhost',
      port: 3000,
      protocol: 'http'
    }
    Rails.application.routes.default_url_options = {
      host: 'localhost',
      port: 3000
    }
  end

  config.before(:each) do
    # Clear job queue before each test
    clear_enqueued_jobs
    clear_performed_jobs
  end
  
  config.after(:each) do
    # Clean up after each test
    clear_enqueued_jobs
    clear_performed_jobs
  end
  
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.include FactoryBot::Syntax::Methods

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
  config.render_views = false

  config.use_transactional_fixtures = true

  config.include Devise::Test::IntegrationHelpers, type: :request

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
