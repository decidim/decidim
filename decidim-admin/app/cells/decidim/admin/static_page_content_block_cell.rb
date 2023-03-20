# frozen_string_literal: true

module Decidim
  module Admin
    class StaticPageContentBlockCell < ContentBlockCell
      delegate :scoped_resource, to: :controller

      def edit_content_block_path
        decidim_admin.edit_static_page_content_block_path(scoped_resource, model)
      end

      def content_block_path
        decidim_admin.static_page_content_block_path(scoped_resource, model)
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end
    end
  end
end
