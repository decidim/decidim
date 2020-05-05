# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes Initiatives versions so users can see how an Initiative
    # has been updated through time.
    class VersionsController < Decidim::Initiatives::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout

      helper Decidim::TraceabilityHelper
      helper InitiativeHelper
      include NeedsInitiative

      helper_method :current_version

      private

      def current_version
        return nil unless params[:id].to_i.positive?

        @current_version ||= current_initiative.versions[params[:id].to_i - 1]
      end
    end
  end
end
