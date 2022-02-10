# frozen_string_literal: true

require "rspec-html-matchers"

module EscapeHtmlHelpers
  def html_escaped(string)
    CGI.escapeHTML(string)
  end

  def have_escaped_html(string)
    include(html_escaped(string))
  end
end

RSpec::Matchers.define(:have_equivalent_markup_to) do |expected|
  cleaner = ->(str) { str.gsub(/>[[:space:]]*/, ">").gsub(/[[:space:]]*</, "<").strip }

  match do |actual|
    cleaner.call(expected) == cleaner.call(actual)
  end

  diffable
end

RSpec.configure do |config|
  config.include RSpecHtmlMatchers
  config.include EscapeHtmlHelpers
end
