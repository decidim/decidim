# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.4.1"

gemspec path: "."

Dir.glob('decidim-*').select do |file|
  gem file, path: file
end
