# frozen_string_literal: true

module Decidim
  module Elections
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Elections::ApplicationController
      include FilterResource
      include Paginable
      include Decidim::Elections::Orderable
      include HasVoteFlow

      helper_method :elections, :election, :paginated_elections, :scheduled_elections, :single?, :onboarding, :authority_public_key, :bulletin_board_server, :authority_slug

      def index
        redirect_to election_path(single, single: true) if single?
      end

      def show
        enforce_permission_to :view, :election, election:
      end

      def election_log; end

      private

      delegate :bulletin_board_server, :authority_slug, to: :bulletin_board_client

      def elections
        @elections ||= search_collection
      end

      def election
        # The single election is searched from non-published records on purpose
        # to allow previewing for admins.
        @election ||= Election.where(component: current_component).find(params[:id])
      end

      def onboarding
        @onboarding ||= params[:onboarding].present?
      end

      def bulletin_board_client
        @bulletin_board_client ||= Decidim::Elections.bulletin_board
      end

      def authority_public_key
        @authority_public_key ||= bulletin_board_client.authority_public_key.to_json
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

      def paginated_elections
        @paginated_elections ||= paginate(search.result.published)
        @paginated_elections = reorder(@paginated_elections)
      end

      def scheduled_elections
        @scheduled_elections ||= search_with(filter_params.merge(with_any_date: %w(active upcoming))).result
      end

      def search_collection
        Election.where(component: current_component).published
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_date: default_filter_date_params
        }
      end

      def default_filter_date_params
        if elections.active.any?
          %w(active)
        elsif elections.upcoming.any?
          %w(upcoming)
        else
          %w()
        end
      end
    end
  end
end
