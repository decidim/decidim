# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes the initiative vote resource so users can vote initiatives.
    class InitiativeVotesController < Decidim::ApplicationController
      include Decidim::Initiatives::NeedsInitiative

      before_action :authenticate_user!

      helper Decidim::ActionAuthorizationHelper
      helper InitiativeHelper
      include Decidim::Initiatives::ActionAuthorization

      # POST /initiatives/:initiative_id/initiative_vote
      def create
        authorize! :vote, current_initiative
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
        authorize! :unvote, current_initiative
        UnvoteInitiative.call(current_initiative, current_user, params[:group_id]) do
          on(:ok) do
            current_initiative.reload
            render :update_buttons_and_counters
          end
        end
      end

      private

      def ability_context
        {
          current_settings: try(:current_settings),
          component_settings: try(:component_settings),
          current_organization: try(:current_organization),
          current_component: try(:current_component),
          params: try(:params)
        }
      end
    end
  end
end
