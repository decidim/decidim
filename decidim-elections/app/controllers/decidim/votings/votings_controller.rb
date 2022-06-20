# frozen_string_literal: true

module Decidim
  module Votings
    # A controller that holds the logic to show votings in a
    # public layout.
    class VotingsController < Decidim::Votings::ApplicationController
      layout "layouts/decidim/voting_landing", only: :show

      include FormFactory
      include ParticipatorySpaceContext
      include NeedsVoting
      include FilterResource
      include Paginable
      include Decidim::Votings::Orderable
      include Decidim::Elections::HasVoteFlow

      helper_method :published_votings, :paginated_votings, :filter, :promoted_votings, :only_finished_votings?, :landing_content_blocks, :census_contact_information

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PaginateHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::ResourceHelper
      helper Decidim::Admin::IconLinkHelper

      def index
        raise ActionController::RoutingError, "Not Found" if published_votings.none?

        enforce_permission_to :read, :votings
        redirect_to voting_path(single) if single?
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless current_participatory_space

        enforce_permission_to :read, :voting, voting: current_participatory_space
      end

      helper_method :election, :exit_path, :election_log_path, :elections

      def login
        @form = form(Census::LoginForm).from_params(params, election: election)

        render :login,
               layout: "decidim/election_votes"
      end

      def show_check_census
        raise ActionController::RoutingError, "Not Found" unless current_participatory_space.check_census_enabled?

        @form = form(Census::CheckForm).instance
        render :check_census, locals: { success: false, not_found: false }
      end

      def check_census
        raise ActionController::RoutingError, "Not Found" unless current_participatory_space.check_census_enabled?

        @form = form(Census::CheckForm).from_params(params).with_context(
          current_participatory_space: current_participatory_space
        )

        success = not_found = false
        datum = nil
        CheckCensus.call(@form) do
          on(:ok) do |census|
            success = true
            datum = census
          end
          on(:not_found) do
            not_found = true
          end
          on(:invalid) do
            flash[:alert] = t("check_census.invalid", scope: "decidim.votings.votings")
          end
        end

        render action: :check_census, locals: { success: success, not_found: not_found, datum: datum }
      end

      def send_access_code
        SendAccessCode.call(datum, params[:medium]) do
          on(:ok) do
            flash[:notice] = t("send_access_code.success", scope: "decidim.votings.votings")
          end
          on(:invalid) do
            flash[:alert] = t("send_access_code.invalid", scope: "decidim.votings.votings")
          end
        end
        render action: :check_census, locals: { success: true, not_found: false, datum: datum }
      end

      def elections_log
        redirect_to election_log_path(elections.first) if elections.length == 1
      end

      private

      def datum
        @datum ||= Decidim::Votings::Census::Datum.find(params[:datum_id])
      end

      def election
        @election ||= Decidim::Elections::Election.find(params[:election_id])
      end

      def elections
        raise ActionController::RoutingError, "Not Found" unless current_participatory_space

        Decidim::Elections::Election.where(component: current_participatory_space.components).where.not(bb_status: nil)
      end

      def exit_path
        EngineRouter.main_proxy(election.component).election_path(election)
      end

      def election_log_path(election)
        EngineRouter.main_proxy(election.component).election_log_election_path(election)
      end

      def census_contact_information
        @census_contact_information ||= current_participatory_space.census_contact_information.presence || t("no_census_contact_information", scope: "decidim.votings.votings")
      end

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:votings)
      end

      def published_votings
        @published_votings ||= Voting.where(organization: current_organization).published
      end

      def paginated_votings
        @paginated_votings ||= paginate(search.result.published)
        @paginated_votings = reorder(@paginated_votings)
      end

      def promoted_votings
        @promoted_votings ||= OrganizationPromotedVotings.new(current_organization)
      end

      def finished_votings
        @finished_votings ||= search_with(filter_params.merge(with_any_date: %w(finished))).result
      end

      def only_finished_votings?
        return if finished_votings.blank?

        published_votings.count == finished_votings.count
      end

      def search_collection
        Voting.where(organization: current_organization).published
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_date: [""]
        }
      end

      # Public: Checks if the component has only one election resource.
      #
      # Returns Boolean.
      def single?
        published_votings.one?
      end

      def single
        published_votings.first if single?
      end

      def landing_content_blocks
        @landing_content_blocks ||= Decidim::ContentBlock.published
                                                         .for_scope(:voting_landing_page, organization: current_organization)
                                                         .where(scoped_resource_id: current_participatory_space.id)
                                                         .reject { |content_block| content_block.manifest.nil? }
      end
    end
  end
end
