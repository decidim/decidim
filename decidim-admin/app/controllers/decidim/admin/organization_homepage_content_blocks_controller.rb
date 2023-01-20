# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization homepage content blocks
    class OrganizationHomepageContentBlocksController < Decidim::Admin::ApplicationController
      include Decidim::Admin::ContentBlocks::LandingPageContentBlocks

      layout "decidim/admin/settings"

      helper_method :content_block

      private

      def content_block_scope
        :homepage
      end

      def scoped_resource
        nil
      end

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def edit_resource_landing_page_path
        edit_organization_homepage_path
      end

      def resource_landing_page_content_block_path
        organization_homepage_content_block_path(params[:id])
      end

      def submit_button_text
        t("organization_homepage.content_blocks.edit.update", scope: "decidim.admin")
      end

      def content_block_create_success_text
        t("organization_homepage.content_blocks.create.success", scope: "decidim.admin")
      end

      def content_block_create_error_text
        t("organization_homepage.content_blocks.create.error", scope: "decidim.admin")
      end

      def content_block_destroy_success_text
        t("organization_homepage.content_blocks.destroy.success", scope: "decidim.admin")
      end

      def content_block_destroy_error_text
        t("organization_homepage.content_blocks.destroy.error", scope: "decidim.admin")
      end
    end
  end
end
