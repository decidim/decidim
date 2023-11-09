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
    end
  end
end
