# frozen_string_literal: true

module Decidim
  module Admin
    class StaticPageContentBlockCell < ContentBlockCell
      def edit_content_block_path
        decidim_admin.edit_static_page_content_block_path(static_page_id, manifest_name)
      end

      def static_page_id
        model.try(:scoped_resource_id) || options[:scoped_resource_id]
      end
    end
  end
end
