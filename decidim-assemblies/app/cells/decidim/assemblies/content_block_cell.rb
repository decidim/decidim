# frozen_string_literal: true

module Decidim
  module Assemblies
    class ContentBlockCell < Decidim::Admin::ContentBlockCell
      delegate :scoped_resource, to: :controller

      def edit_content_block_path
        decidim_assemblies.edit_assembly_landing_page_content_block_path(scoped_resource, model)
      end

      def content_block_path
        decidim_assemblies.assembly_landing_page_content_block_path(scoped_resource, model)
      end

      def decidim_assemblies
        Decidim::Assemblies::AdminEngine.routes.url_helpers
      end
    end
  end
end
