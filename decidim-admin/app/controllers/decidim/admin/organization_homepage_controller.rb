# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization homepage
    class OrganizationHomepageController < Decidim::Admin::ApplicationController
      include Decidim::Admin::ContentBlocks::LandingPage

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      def content_block_scope
        :homepage
      end

      def scoped_resource
        nil
      end

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def resource_sort_url
        organization_homepage_path
      end

      def resource_create_url(manifest_name)
        organization_homepage_content_blocks_path(manifest_name:)
      end

      def content_blocks_title
        t("organization_homepage.edit.title", scope: "decidim.admin")
      end

      def add_content_block_text
        t("organization_homepage.edit.add", scope: "decidim.admin")
      end

      def content_block_destroy_confirmation_text
        t("organization_homepage.edit.destroy_confirmation", scope: "decidim.admin")
      end

      def active_content_blocks_title
        t("organization_homepage.edit.active_content_blocks", scope: "decidim.admin")
      end

      def inactive_content_blocks_title
        t("organization_homepage.edit.inactive_content_blocks", scope: "decidim.admin")
      end

      def resource_content_block_cell
        "decidim/admin/homepage_content_block"
      end
    end
  end
end
