# frozen_string_literal: true

module Decidim
  module Consultations
    class ConsultationWidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      layout false

      private

      def model
        @model ||= Consultation.find_by(slug: params[:consultation_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= consultation_consultation_widget_url(model)
      end
    end
  end
end
