# frozen_string_literal: true

module FiltersHelpers
  def click_filter_item(text)
    find("label.filter", text:).click
  end
end

RSpec.configure do |config|
  config.include FiltersHelpers, type: :system
end
