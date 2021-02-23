# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage menus in admin layout
    module MenuHelper
      include Decidim::Admin::SidebarMenuHelper

      # Public: Returns the main menu presenter object
      def main_menu
        @main_menu ||= ::Decidim::MenuPresenter.new(
          :admin_menu,
          self,
          active_class: "is-active"
        )
      end

      def global_moderation_menu
        @global_moderation_menu ||= sidebar_menu(:admin_global_moderation_menu)
      end

      def organization_settings_menu
        @organization_settings_menu ||= sidebar_menu(:admin_settings_menu)
      end
    end
  end
end
