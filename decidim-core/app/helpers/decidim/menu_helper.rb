# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage menus in layout
  module MenuHelper
    # Public: Returns the main menu presenter object
    def main_menu
      @main_menu ||= ::Decidim::MenuPresenter.new(
        :menu,
        self,
        element_class: "main-nav__link",
        active_class: "main-nav__link--active"
      )
    end

    # Public: Returns the user menu presenter object
    def user_menu
      @user_menu ||= ::Decidim::InlineMenuPresenter.new(
        :user_menu,
        self,
        element_class: "tabs-title",
        active_class: "is-active"
      )
    end
  end
end
