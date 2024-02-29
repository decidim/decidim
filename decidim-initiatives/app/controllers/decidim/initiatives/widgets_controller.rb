# frozen_string_literal: true

module Decidim
  module Initiatives
    # This controller provides a widget that allows embedding the initiative
    class WidgetsController < Decidim::WidgetsController
      helper InitiativesHelper
      helper PaginateHelper
      helper InitiativeHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper

      include NeedsInitiative

      def show
        enforce_permission_to :embed, :participatory_space, current_participatory_space: model if model

        super
      end

      private

      def model
        @model ||= current_initiative
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= initiative_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Initiatives::ApplicationController)
      end
    end
  end
end
