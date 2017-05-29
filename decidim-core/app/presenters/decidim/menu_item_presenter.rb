# frozen_string_literal: true

module Decidim
  # A presenter to render menu items
  class MenuItemPresenter
    #
    # Initializes a menu item for presentation
    #
    # @param menu_item [MenuItem] The menu item itself
    # @param view [ActionView::Base] The view instance to help rendering the item
    # @param options [Hash] The rendering options for the item
    #
    # @option options [String] :element_class
    #         The CSS class to be used for the item
    #
    # @option options [String] :active_class
    #         The CSS class to be used for the active item
    #
    def initialize(menu_item, view, options = {})
      @menu_item = menu_item
      @view = view
      @element_class = options[:element_class]
      @active_class = options[:active_class]
    end

    delegate :label, :url, :active, :icon_name, to: :@menu_item
    delegate :content_tag, :link_to, :active_link_to_class, :is_active_link?, :icon, to: :@view

    def render
      content_tag :li, class: link_wrapper_classes do
        if icon_name
          link_to(url) { icon(icon_name) + label }
        else
          link_to label, url
        end
      end
    end

    private

    attr_reader :element_class

    def link_wrapper_classes
      return element_class unless is_active_link?(url, active)

      [element_class, active_class].compact.join(" ")
    end

    def active_class
      active_link_to_class(
        url,
        active: active,
        class_active: @active_class
      )
    end
  end
end
