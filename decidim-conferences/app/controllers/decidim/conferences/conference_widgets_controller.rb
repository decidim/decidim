# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceWidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      private

      def model
        @model ||= Conference.where(organization: current_organization).find_by(slug: params[:conference_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= conference_conference_widget_url(model)
      end
    end
  end
end
