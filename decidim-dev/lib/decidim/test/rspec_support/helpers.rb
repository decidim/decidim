# frozen_string_literal: true

# Helpers that get automatically included in feature specs.
module Decidim::FeatureTestHelpers
  def within_user_menu
    within ".topbar__user__logged" do
      find("a", text: user.name).hover
      yield
    end
  end

  def within_language_menu
    within ".topbar__dropmenu.language-choose" do
      find("ul.dropdown.menu").hover
      yield
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::FeatureTestHelpers, type: :feature
end
