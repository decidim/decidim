# frozen_string_literal: true

module Decidim
  module Admin
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :public_name_key, :has_settings?, to: :model

      def manifest_name
        model.try(:manifest_name) || model.name
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end
    end
  end
end
