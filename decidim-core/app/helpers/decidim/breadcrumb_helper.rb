# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage breadcrumb in layout
  module BreadcrumbHelper
    attr_reader :context_breadcrumb_items

    def breadcrumb_items(context = :public)
      @breadcrumb_items ||= [].tap do |items|
        active_item = if context == :admin
                        breadcrumb_root_admin_menu.active_item || breadcrumb_modules_admin_menu.active_item
                      else
                        breadcrumb_root_menu.active_item
                      end

        if active_item.present?
          items << {
            label: active_item.label,
            url: active_item.url,
            active: active_item.active? && context_breadcrumb_items.blank?
          }
        end

        items.append(*context_breadcrumb_items)
      end
    end
  end
end
