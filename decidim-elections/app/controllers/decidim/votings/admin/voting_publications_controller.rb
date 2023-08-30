# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing voting publications.
      #
      class VotingPublicationsController < Admin::ApplicationController
        include VotingAdmin

        def create
          enforce_permission_to :publish, :voting, voting: current_voting

          PublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.publish.success", scope: "decidim.votings.admin")
              redirect_to edit_voting_path(voting)
            end
          end
        end

        def destroy
          enforce_permission_to :unpublish, :voting, voting: current_voting

          UnpublishVoting.call(current_voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.unpublish.success", scope: "decidim.votings.admin")
              redirect_to edit_voting_path(voting)
            end
          end
        end
      end
    end
  end
end
