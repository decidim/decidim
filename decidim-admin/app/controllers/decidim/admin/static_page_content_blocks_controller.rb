# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization privacy policy content blocks
    class StaticPageContentBlocksController < Decidim::Admin::ApplicationController
      include Decidim::Admin::ContentBlocks::LandingPageContentBlocks

      helper_method :page

      private

      def content_block_scope
        :static_page
      end

      def scoped_resource
        @scoped_resource ||= collection.find_by(slug: params[:static_page_id])
      end

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :static_page, static_page: scoped_resource
      end

      def edit_resource_landing_page_path
        edit_static_page_path(scoped_resource.slug)
      end

      def resource_landing_page_content_block_path
        static_page_content_block_path(scoped_resource, params[:id])
      end

      def submit_button_text
        t("static_pages.content_blocks.edit.update", scope: "decidim.admin")
      end

      def content_block_create_success_text
        t("static_pages.content_blocks.create.success", scope: "decidim.admin")
      end

      def content_block_create_error_text
        t("static_pages.content_blocks.create.error", scope: "decidim.admin")
      end

      def content_block_destroy_success_text
        t("static_pages.content_blocks.destroy.success", scope: "decidim.admin")
      end

      def content_block_destroy_error_text
        t("static_pages.content_blocks.destroy.error", scope: "decidim.admin")
      end

      def collection
        @collection ||= current_organization.static_pages
      end

      alias page scoped_resource
    end
  end
end
