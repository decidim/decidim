# frozen_string_literal: true

module Decidim
  module Consultations
    class ConsultationWidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper
      helper ConsultationsHelper

      layout false

      def show
        enforce_permission_to :embed, :participatory_space, current_participatory_space: model if model

        super
      end

      private

      def model
        @model ||= Consultation.where(organization: current_organization).published.find_by(slug: params[:consultation_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= consultation_consultation_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Consultations::ApplicationController)
      end
    end
  end
end
