# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", path: "."
gem "decidim-conferences", path: "."
gem "decidim-consultations", path: "."
gem "decidim-elections", path: "."
gem "decidim-initiatives", path: "."
gem "decidim-templates", path: "."

gem "bootsnap", "~> 1.4"

gem "puma", ">= 5.6.2"

gem "faker", "~> 2.14"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", path: "."

  gem "brakeman", "~> 5.2"
  gem "parallel_tests", "~> 3.7"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end
