# frozen_string_literal: true

module Decidim
  module Assemblies
    class WidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      def show
        enforce_permission_to :embed, :participatory_space, current_participatory_space: model if model

        super
      end

      private

      def model
        @model ||= Assembly.where(organization: current_organization).public_spaces.find_by(slug: params[:assembly_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= assembly_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Assemblies::ApplicationController)
      end
    end
  end
end
