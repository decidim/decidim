# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Handles the KeyCeremony for trustee users
      class ElectionsController < Decidim::Elections::TrusteeZone::ApplicationController
        helper_method :election

        def show
          enforce_permission_to :view, :election, trustee: trustee
        end

        def update
          enforce_permission_to :update, :election, trustee: trustee

          UpdateElectionBulletinBoardStatus.call(election, params[:status]) do
            on(:ok) do
              render :update
            end
            on(:invalid) do
              flash[:alert] = I18n.t("elections.update.error", scope: "decidim.elections.trustee_zone")
            end
          end
        end

        private

        def election
          @election ||= Decidim::Elections::Election.find(params[:election_id])
        end
      end
    end
  end
end
