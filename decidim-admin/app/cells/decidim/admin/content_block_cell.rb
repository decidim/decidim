# frozen_string_literal: true

module Decidim
  module Admin
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :public_name_key, :has_settings?, to: :model

      def manifest_name
        model.try(:manifest_name) || model.name
      end

      def edit_content_block_path
        decidim_admin.edit_organization_homepage_content_block_path(manifest_name)
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end
    end
  end
end
