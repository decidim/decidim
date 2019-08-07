# frozen_string_literal: true

RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    page.body.index(earlier_content) < page.body.index(later_content)
  rescue ArgumentError
    raise "Could not locate later content on page: #{later_content}"
  rescue NoMethodError
    raise "Could not locate earlier content on page: #{earlier_content}"
  end
end
