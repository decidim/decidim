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
      @options = OpenStruct.new(options)
    end

    delegate :label, :url, :active, :icon_name, to: :@menu_item
    delegate :content_tag, :safe_join, :link_to, :active_link_to_class, :is_active_link?, :icon, to: :@view

    def render
      content_tag :li, class: link_wrapper_classes do
        output = [link_to(composed_label, url, link_options)]
        output.push(@view.send(:simple_menu, **@menu_item.submenu).render) if @menu_item.submenu

        safe_join(output)
      end
    end

    private

    def link_options
      if is_active_link?(url, active)
        { aria: { current: "page" } }
      else
        {}
      end
    end

    def composed_label
      icon_name.present? ? icon(icon_name) + label : label
    end

    def link_wrapper_classes
      return @options.element_class unless is_active_link?(url, active)

      [@options.element_class, active_class].compact.join(" ")
    end

    def active_class
      active_link_to_class(
        url,
        active:,
        class_active: @options.active_class
      )
    end
  end
end
