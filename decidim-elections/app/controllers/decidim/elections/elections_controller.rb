# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Elections::ApplicationController
      include Paginable

      helper_method :elections, :election, :paginated_elections

      def show
        enforce_permission_to :view, :election, election: election
      end

      private

      def elections
        @elections ||= Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:id])
      end

      def paginated_elections
        @paginated_elections ||= paginate(elections.published)
      end
    end
  end
end
