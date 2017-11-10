# frozen_string_literal: true

module Decidim
  # A presenter to render menus
  class UserMenuPresenter < MenuPresenter
    def render
      safe_join(menu_items)
    end
  end
end
