# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Handles the KeyCeremony for trustee users
      class ElectionsController < ::Decidim::ApplicationController
        include Decidim::UserProfile

        helper_method :election, :trustee

        def show
          # TODO: Set permissions
        end

        def update
          # TODO: Set permissions
          # enforce_permission_to :update, :election, trustee: trustee
          UpdateElectionBulletinBoardStatus.call(election, :key_ceremony) do
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

        def trustee
          @trustee ||= Decidim::Elections::Trustee.for(current_user)
        end
      end
    end
  end
end
