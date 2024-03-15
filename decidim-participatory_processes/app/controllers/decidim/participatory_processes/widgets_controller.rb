# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class WidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      def show
        enforce_permission_to :embed, :participatory_space, current_participatory_space: model

        super
      end

      private

      def model
        return unless params[:participatory_process_slug]

        @model ||= ParticipatoryProcess.where(organization: current_organization).public_spaces.where(slug: params[:participatory_process_slug]).or(
          ParticipatoryProcess.where(organization: current_organization).public_spaces.where(id: params[:participatory_process_slug])
        ).first!
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= participatory_process_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::ApplicationController)
      end
    end
  end
end
