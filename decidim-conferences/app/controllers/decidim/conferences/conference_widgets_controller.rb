# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferenceWidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      def show
        enforce_permission_to :embed, :conference, conference: model if model

        super
      end

      private

      def model
        @model ||= Conference.where(organization: current_organization).published.find_by(slug: params[:conference_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= conference_conference_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Conferences::ApplicationController)
      end
    end
  end
end
