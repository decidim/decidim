# frozen_string_literal: true

module Decidim
  module Admin
    class HomepageContentBlockCell < ContentBlockCell
      def edit_content_block_path
        decidim_admin.edit_organization_homepage_content_block_path(model)
      end

      def content_block_path
        decidim_admin.organization_homepage_content_block_path(model)
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end
    end
  end
end
