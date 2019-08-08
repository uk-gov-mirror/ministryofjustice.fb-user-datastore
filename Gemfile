source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'bootsnap', '>= 1.1.0', require: false
gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.0'
gem 'nokogiri', '~> 1.10.3'
gem 'jwt'
gem 'sentry-raven'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '>= 3.5.0'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'rswag-specs'
end

group :development do
  gem 'listen'
  gem 'guard-rspec', require: false
  gem 'rswag-api'
  gem 'rswag-ui'
  gem 'guard-shell'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'simplecov'
  gem 'simplecov-console', require: false
  gem 'webmock'
  gem 'timecop'
end

gem 'tzinfo-data'
