# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", path: "."
gem "decidim-ai", path: "."
gem "decidim-collaborative_texts", path: "."
gem "decidim-conferences", path: "."
gem "decidim-demographics", path: "."
gem "decidim-design", path: "."
gem "decidim-elections", path: "."
gem "decidim-initiatives", path: "."
gem "decidim-templates", path: "."

gem "bootsnap", "~> 1.23"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 13.0", platform: :mri

  gem "decidim-dev", path: "."

  gem "brakeman", "~> 8.0"
  gem "parallel_tests", "~> 4.2"
end

group :development do
  gem "letter_opener_web", "~> 3.0"
  gem "listen", "~> 3.10"
  gem "web-console", "~> 4.3"
end
