# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes the initiative vote resource so users can vote initiatives.
    class InitiativeVotesController < Decidim::Initiatives::ApplicationController
      include Decidim::Initiatives::NeedsInitiative

      before_action :authenticate_user!

      helper Decidim::ActionAuthorizationHelper
      helper InitiativeHelper
      include Decidim::Initiatives::ActionAuthorization

      # POST /initiatives/:initiative_id/initiative_vote
      def create
        enforce_permission_to :vote, :initiative, initiative: current_initiative
        VoteInitiative.call(current_initiative, current_user, params[:group_id]) do
          on(:ok) do
            current_initiative.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: {
              error: I18n.t("initiative_votes.create.error", scope: "decidim.initiatives")
            }, status: 422
          end
        end
      end

      # DELETE /initiatives/:initiative_id/initiative_vote
      def destroy
        enforce_permission_to :unvote, :initiative, initiative: current_initiative
        UnvoteInitiative.call(current_initiative, current_user, params[:group_id]) do
          on(:ok) do
            current_initiative.reload
            render :update_buttons_and_counters
          end
        end
      end
    end
  end
end
