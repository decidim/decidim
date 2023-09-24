# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage breadcrumb in layout
  module BreadcrumbHelper
    attr_reader :context_breadcrumb_items, :secondary_breadcrumb_menus, :controller_breadcrumb_items

    # Public: Returns the list of breadcrumb items to be rendered in some
    # context.
    #
    # context - The context (public or admin) to display the breadcrumb. It
    #           determines the first element of the breadcrumb
    #
    # The items are generated as the concatenation of the following 4
    # sections in order:
    # * The root active item: This item comes from the main menu on each
    #   context and is the currently active element.
    # * context_breadcrumb_items: A list which can be implemented in
    #   specific concerns and is used to display items like a participatory
    #   space or a component inside a participatory space.
    # * secondary_breadcrumb_menus: A list which can be managed from
    #   HasBreadcrumbItems concern with the add_breadcrumb_item_from_menu
    #   method. The list contains the identifier of a menu to insert its items
    #   in the breadcrumb displaying the active element.
    # * controller_breadcrumb_items: A list of additional breadrumb items
    #   which is expected to receive its elements from controllers and contains
    #   the last items of the breadcrumb.
    def breadcrumb_items(context = :public)
      @breadcrumb_items ||= [].tap do |items|
        root_active_item = if context == :admin
                             active_breadcrumb_item(:admin_menu_modules) || active_breadcrumb_item(:admin_menu)
                           else
                             active_breadcrumb_item(:menu)
                           end

        items << root_active_item if root_active_item.present?

        items.append(*context_breadcrumb_items)

        secondary_breadcrumb_menus&.each do |menu|
          active_item = active_breadcrumb_item(menu)
          items << active_item if active_item.present?
        end
        items.append(*controller_breadcrumb_items)
      end
    end

    def active_breadcrumb_item(target_menu)
      active_item = ::Decidim::MenuPresenter.new(target_menu, self).active_item

      return if active_item.blank?

      {
        label: active_item.label,
        url: active_item.url,
        active: active_item.active?
      }
    end
  end
end
