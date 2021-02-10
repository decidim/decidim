# frozen_string_literal: true

module Decidim
  module Votings
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :public_name_key, :has_settings?, to: :model
      delegate :current_participatory_space, to: :controller

      def manifest_name
        model.try(:manifest_name) || model.name
      end

      def decidim_votings
        Decidim::Votings::AdminEngine.routes.url_helpers
      end
    end
  end
end
