# frozen_string_literal: true

module Decidim
  # A presenter to render breadcrumb root menu
  class BreadcrumbRootMenuPresenter < MenuPresenter
    def render
      render_menu
    end

    protected

    def menu_items
      items.map do |menu_item|
        BreadcrumbRootMenuItemPresenter.new(menu_item, @view, @options).render
      end
    end
  end
end
