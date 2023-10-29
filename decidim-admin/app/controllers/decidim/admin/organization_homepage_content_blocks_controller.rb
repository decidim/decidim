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

      def i18n_scope = "decidim.admin.organization_homepage.content_blocks"

      def submit_button_text =  t("edit.update", scope: i18n_scope)

      def content_block_create_success_text = t("create.success", scope: i18n_scope)

      def content_block_create_error_text = t("create.error", scope: i18n_scope)

      def content_block_destroy_success_text = t("destroy.success", scope: i18n_scope)

      def content_block_destroy_error_text = t("destroy.error", scope: i18n_scope)
    end
  end
end
