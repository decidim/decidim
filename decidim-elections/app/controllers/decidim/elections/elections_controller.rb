# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Elections::ApplicationController
      include FilterResource
      include Paginable
      include Orderable
      include Decidim::Elections::Orderable

      helper_method :elections, :election, :paginated_elections

      def show
        enforce_permission_to :view, :election, election: election
      end

      private

      def elections
        @elections ||= paginate(search.results)
        @elections = reorder(@elections)
      end

      def election
        @election ||= Election.where(component: current_component).find(params[:id])
      end

      def paginated_elections
        @paginated_elections ||= paginate(elections.published)
      end

      def search_klass
        ElectionSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: %w(active)
        }
      end
    end
  end
end
