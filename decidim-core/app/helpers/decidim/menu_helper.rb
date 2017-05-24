# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage menus in layout
  module MenuHelper
    # Public: Returns the main menu presenter object
    def main_menu
      @main_menu ||= MenuPresenter.new(Menu.find(:menu), self)
    end
  end
end
