# frozen_string_literal: true

module FiltersHelpers
  def click_filter_item(text)
    find("div.filter > label", text:).click
  end
end

RSpec.configure do |config|
  config.include FiltersHelpers, type: :system
end
