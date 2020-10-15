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
    end
  end
end
