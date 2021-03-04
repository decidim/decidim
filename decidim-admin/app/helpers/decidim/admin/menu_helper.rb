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

      def workflows_menu
        @workflows_menu ||= simple_menu(target_menu: :workflows_menu)
      end

      def impersonate_menu
        @impersonate_menu ||= simple_menu(target_menu: :impersonate_menu)
      end
    end
  end
end
