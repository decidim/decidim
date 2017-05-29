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

    delegate :label, :url, :active, to: :@menu_item
    delegate :content_tag, :active_link_to, :active_link_to_class, to: :@view

    def as_link
      content_tag :li do
        active_link_to label, url, link_options
      end
    end

    private

    def element_class
      "main-nav__link",
    end

    def active_class
      active_link_to_class(
        url,
        active: active,
        class_active: "main-nav__link--active"
      )
    end

    def link_options
      {
        active: active,
        class: element_class,
        class_active: active_class
      }
    end
  end
end
