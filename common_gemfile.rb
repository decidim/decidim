# frozen_string_literal: true
source "https://rubygems.org"

ruby '2.3.1'

gem "pg"

# Rails 5 deps
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2"
gem "jquery-rails"
gem "turbolinks", "~> 5"
gem "jbuilder", "~> 2.5"

group :development do
  gem "byebug"
  gem "listen"
end

group :test do
  gem "capybara", "~> 2.4"
  gem "rspec-rails", "~> 3.5"
end
