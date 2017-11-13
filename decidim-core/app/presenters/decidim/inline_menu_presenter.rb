# frozen_string_literal: true

module Decidim
  # A presenter to render inline menus
  class InlineMenuPresenter < MenuPresenter
    def render
      safe_join(menu_items)
    end
  end
end
