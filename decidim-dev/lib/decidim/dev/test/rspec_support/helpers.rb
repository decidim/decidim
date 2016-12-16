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

  def click_icon(name = nil)
    classes = ["icon"]
    classes << ["icon--#{name}"] if name
    find(".#{classes.join(".")}").click
  end

  def stripped(text)
    Nokogiri::HTML(text).text
  end

  def within_flash_messages
    within ".flash.callout" do
      yield
    end
  end
end

def stripped(text)
  Nokogiri::HTML(text).text
end

RSpec.configure do |config|
  config.include Decidim::FeatureTestHelpers, type: :feature
end
