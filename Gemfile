# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", path: "."
gem "decidim-consultations", path: "."
gem "decidim-initiatives", path: "."

# Use unreleased 5-1-stable because 5.1.6 is not compatible with capybara 3.0
# and 5.1.7 is not yet released
gem "rails", git: "https://github.com/rails/rails", branch: "5-1-stable"

gem "puma", "~> 3.0"
gem "uglifier", "~> 4.1"

gem "faker", "~> 1.8"

group :development, :test do
  gem "byebug", "~> 10.0", platform: :mri

  gem "decidim-dev", path: "."
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
