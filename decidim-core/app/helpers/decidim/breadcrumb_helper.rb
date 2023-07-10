# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage breadcrumb in layout
  module BreadcrumbHelper
    attr_reader :context_breadcrumb_items

    def breadcrumb_items
      @breadcrumb_items ||= [].tap do |items|
        if breadcrumb_root_menu.active_item.present?
          items << {
            label: breadcrumb_root_menu.active_item.label,
            url: breadcrumb_root_menu.active_item.url,
            active: breadcrumb_root_menu.active_item.active? && context_breadcrumb_items.blank?
          }
        end

        items.append(*context_breadcrumb_items)
      end
    end
  end
end
