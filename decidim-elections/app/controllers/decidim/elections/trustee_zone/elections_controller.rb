# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Handles the KeyCeremony for trustee users
      class ElectionsController < Decidim::Elections::TrusteeZone::ApplicationController
        helper_method :election, :server, :authority_slug, :authority_public_key, :current_step

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

        delegate :server, to: :bulletin_board_client

        def election
          @election ||= Decidim::Elections::Election.find(params[:election_id])
        end

        def bulletin_board_client
          @bulletin_board_client ||= Decidim::Elections.bulletin_board
        end

        def authority_slug
          @authority_slug ||= bulletin_board_client.authority_name.parameterize
        end

        def authority_public_key
          @authority_public_key ||= bulletin_board_client.public_key.to_json
        end

        def current_step
          @current_step ||= election.bb_status if election.bb_key_ceremony? || election.bb_tally?
        end
      end
    end
  end
end
