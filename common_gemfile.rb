source 'https://rubygems.org'

gem 'pg'

group :development do
  gem 'byebug'
  gem 'listen'
end

group :test do
  gem 'capybara', '~> 2.4'
  gem 'rspec-rails', '~> 3.5'
end
