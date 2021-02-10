# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Elections::ApplicationController
      include FilterResource
      include Paginable
      include Decidim::Elections::Orderable

      helper_method :elections, :election, :paginated_elections, :scheduled_elections, :single?, :last_vote

      def index
        redirect_to election_path(single, single: true) if single?
      end

      def show
        enforce_permission_to :view, :election, election: election
      end

      private

      def elections
        @elections ||= Election.where(component: current_component).published
      end

      def election
        @election ||= Election.where(component: current_component).find(params[:id])
      end

      # Public: Checks if the component has only one election resource.
      #
      # Returns Boolean.
      def single?
        elections.one?
      end

      def single
        elections.first if single?
      end

      def last_vote
        @last_vote ||= Decidim::Elections::Votes::UserElectionLastVote.new(current_user, election).query
      end

      def paginated_elections
        @paginated_elections ||= paginate(search.results.published)
        @paginated_elections = reorder(@paginated_elections)
      end

      def scheduled_elections
        @scheduled_elections ||= search_klass.new(search_params.merge(state: %w(active upcoming))).results
      end

      def search_klass
        ElectionSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: default_filter_state_params
        }
      end

      def default_filter_state_params
        if elections.active.any?
          %w(active)
        elsif elections.upcoming.any?
          %w(upcoming)
        else
          %w()
        end
      end

      def context_params
        { component: current_component, organization: current_organization }
      end
    end
  end
end
