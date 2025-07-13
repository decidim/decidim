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

      def resource_content_block_cell
        "decidim/admin/homepage_content_block"
      end

      def content_blocks_title
        t("decidim.admin.menu.homepage")
      end
    end
  end
end
