# frozen_string_literal: true

require "rspec-html-matchers"

RSpec::Matchers.define(:have_equivalent_markup_to) do |expected|
  cleaner = ->(str) { str.gsub(/>[[:space:]]*/, ">").gsub(/[[:space:]]*</, "<").strip }

  match do |actual|
    cleaner.call(expected) == cleaner.call(actual)
  end

  diffable
end

RSpec.configure do |config|
  config.include RSpecHtmlMatchers
end
