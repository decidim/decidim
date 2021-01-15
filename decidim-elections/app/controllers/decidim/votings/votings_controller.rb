# frozen_string_literal: true

module Decidim
  module Votings
    # A controller that holds the logic to show votings in a
    # public layout.
    class VotingsController < Decidim::Votings::ApplicationController
      include ParticipatorySpaceContext
      include NeedsVoting
      include FilterResource
      include Paginable
      include Decidim::Votings::Orderable

      helper_method :collection, :votings, :finished_votings, :active_votings, :filter

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PaginateHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::ResourceHelper

      def index
        enforce_permission_to :read, :votings
      end

      def show
        enforce_permission_to :read, :voting, voting: current_voting
      end

      private

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:votings)
      end

      def votings
        @votings = search.results
        @votings = reorder(@votings)
        @votings = paginate(@votings)
      end

      alias collection votings

      def search_klass
        VotingSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: "all"
        }
      end

      def context_params
        {
          organization: current_organization,
          current_user: current_user
        }
      end
    end
  end
end
