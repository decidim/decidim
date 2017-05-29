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
    delegate :content_tag, :active_link_to, to: :@view

    def as_link
      content_tag :li do
        active_link_to label, url, link_options
      end
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
