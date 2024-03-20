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
        @model ||= if current_initiative.created? || current_initiative.validating? || current_initiative.discarded?
                     nil
                   else
                     current_initiative
                   end
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
