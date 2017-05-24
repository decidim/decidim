# frozen_string_literal: true

module Decidim
  # A presenter to render menu items
  class MenuItemPresenter
    #
    # Initializes a menu item for presentation
    #
    # @param menu_item [MenuItem] The menu item itself
    # @param view [ActionView::Base] The view instance to help rendering the item
    #
    def initialize(menu_item, view)
      @menu_item = menu_item
      @view = view
    end

    delegate :label, :url, :options, to: :@menu_item
    delegate :active_link_to, to: :@view

    def as_link
      active_link_to label(@view), url(@view), link_options
    end

    private

    def link_options
      {
        active: options[:active],
        class: "main-nav__link",
        class_active: "main-nav__link--active"
      }
    end
  end
end
