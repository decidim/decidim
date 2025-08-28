# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage menus in admin layout
    module MenuHelper
      # Public: Returns the main menu presenter object
      def main_menu
        @main_menu ||= ::Decidim::MenuPresenter.new(
          :admin_menu,
          self,
          active_class: "is-active",
          label: t("layouts.decidim.header.main_menu")
        )
      end

      def main_menu_modules
        @main_menu_modules ||= ::Decidim::MenuPresenter.new(
          :admin_menu_modules,
          self,
          container_options: { class: "main-nav__modules" },
          active_class: "is-active",
          label: t("layouts.decidim.header.main_menu")
        )
      end

      def dropdown_menu(target_menu)
        ::Decidim::Admin::SecondaryMenuPresenter.new(
          target_menu,
          self,
          container_options: { class: "dropdown dropdown__bottom" },
          element_class: "dropdown__button",
          element_wrapper_class: "dropdown__item",
          active_class: "is-active"
        )
      end

      def sidebar_menu(target_menu)
        ::Decidim::Admin::SecondaryMenuPresenter.new(
          target_menu,
          self,
          element_wrapper_class: "sidebar-menu__item",
          active_class: "is-active"
        )
      end

      def admin_tabs(target_menu)
        ::Decidim::MenuPresenter.new(
          target_menu,
          self,
          container_options: { class: "tab-x-container" },
          active_class: "is-active"
        )
      end

      def breadcrumb_modules_admin_menu
        @breadcrumb_modules_admin_menu ||= ::Decidim::BreadcrumbRootMenuPresenter.new(
          :admin_menu_modules,
          self,
          container_options: { class: "menu-bar__main-dropdown__menu" }
        )
      end

      def breadcrumb_root_admin_menu
        @breadcrumb_root_admin_menu ||= ::Decidim::BreadcrumbRootMenuPresenter.new(
          :admin_menu,
          self,
          container_options: { class: "menu-bar__main-dropdown__menu" }
        )
      end

      def simple_menu(target_menu:, options: {})
        options = { active_class: "is-active" }.merge(options)
        ::Decidim::Admin::SimpleMenuPresenter.new(target_menu, self, options)
      end

      def add_secondary_root_menu(menu)
        @secondary_root_menu = menu
      end

      attr_reader :secondary_root_menu

      def has_secondary_root_menu?
        @secondary_root_menu.present?
      end
    end
  end
end
