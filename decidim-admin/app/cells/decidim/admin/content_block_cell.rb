# frozen_string_literal: true

module Decidim
  module Admin
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      def i18n_name_key
        model.i18n_name_key
      end

      def manifest_name
        model.try(:manifest_name) || model.name
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end
    end
  end
end