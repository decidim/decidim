# frozen_string_literal: true

module Decidim
  # This module includes helpers to manage menus in layout
  module MenuHelper
    # Public: Returns the main menu presenter object
    def main_menu
      @main_menu ||= ::Decidim::MenuPresenter.new(
        :menu,
        self,
        element_class: "main-nav__link",
        active_class: "main-nav__link--active",
        label: t("layouts.decidim.header.main_menu")
      )
    end

    def main_menu_modules
      @main_menu ||= ::Decidim::MenuPresenter.new(
        :menu,
        self,
        element_class: "main-nav__link-modules",
        active_class: "main-nav__link-modules--active",
        label: t("layouts.decidim.header.main_menu")
      )
    end

    # Public: Returns the user menu presenter object
    def user_menu
      @user_menu ||= ::Decidim::InlineMenuPresenter.new(
        :user_menu,
        self,
        element_class: "tabs-title",
        active_class: "is-active",
        label: t("layouts.decidim.user_menu.title")
      )
    end

    def breadcrumb_root_menu
      @breadcrumb_root_menu ||= ::Decidim::BreadcrumbRootMenuPresenter.new(
        :menu,
        self,
        container_options: { class: "menu-bar__dropdown-menu" }
      )
    end

    def mobile_breadcrumb_root_menu
      @mobile_breadcrumb_root_menu ||= ::Decidim::BreadcrumbRootMenuPresenter.new(
        :mobile_menu,
        self,
        container_options: { class: "menu-bar__main-dropdown__top-menu" }
      )
    end

    def footer_menu
      @footer_menu ||= ::Decidim::FooterMenuPresenter.new(
        :menu,
        self,
        element_class: "font-semibold underline",
        active_class: "is-active",
        container_options: { class: "space-y-4 break-inside-avoid", role: :menu },
        label: t("layouts.decidim.footer.decidim_title")
      )
    end

    def menu_highlighted_participatory_process
      return if current_user.blank? && current_organization&.force_users_to_authenticate_before_access_organization

      @menu_highlighted_participatory_process ||= (
        # The queries already include the order by weight
        Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(current_organization) |
        Decidim::ParticipatoryProcesses::PromotedParticipatoryProcesses.new
      ).first
    end

    def home_content_block_menu
      @home_content_block_menu ||= ::Decidim::MenuPresenter.new(
        :home_content_block_menu,
        self,
        element_class: "main-nav__link",
        active_class: "main-nav__link--active",
        label: t("layouts.decidim.header.main_menu")
      )
    end
  end
end
