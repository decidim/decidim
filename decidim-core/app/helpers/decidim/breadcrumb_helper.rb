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
            active: breadcrumb_root_menu.active_item.active?
          }
        end

        items.append(*context_breadcrumb_items)

        empty_path = [
          "/",
          "/users",
          "/users/sign_in",
          "/users/sign_up",
          "/users/password/new",
          "/users/password/edit",
          "/users/confirmation/new",
          "/users/unlock/new"
        ].any? { |path| is_active_link?(path, :exclusive) }

        empty_path ||= [
          "Decidim::Devise::InvitationsController",
          "Decidim::ErrorsController"
        ].any? { |controller_class_name| controller.class.to_s == controller_class_name }

        raise "Missing breadcrumb, breadcrumb has only #{items.count} elements for controller #{controller.class.to_s}" if !empty_path && items.empty?
      end
    end
  end
end
