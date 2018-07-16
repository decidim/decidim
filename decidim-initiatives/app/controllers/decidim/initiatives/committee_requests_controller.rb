# frozen_string_literal: true

module Decidim
  module Initiatives
    # Controller in charge of managing committee membership
    class CommitteeRequestsController < Decidim::Initiatives::ApplicationController
      include Decidim::Initiatives::NeedsInitiative

      helper InitiativeHelper
      helper Decidim::ActionAuthorizationHelper

      layout "layouts/decidim/application"

      # GET /initiatives/:initiative_id/committee_requests/new
      def new
        enforce_permission_to :request_membership, :initiative, initiative: current_initiative
      end

      # GET /initiatives/:initiative_id/committee_requests/spawn
      def spawn
        enforce_permission_to :request_membership, :initiative, initiative: current_initiative

        SpawnCommitteeRequest.call(current_initiative, current_user) do
          on(:ok) do
            redirect_to initiatives_path, flash: {
              notice: I18n.t(
                "success",
                scope: %w(decidim initiatives committee_requests spawn)
              )
            }
          end

          on(:invalid) do |request|
            redirect_to initiatives_path, flash: {
              error: request.errors.full_messages.to_sentence
            }
          end
        end
      end
    end
  end
end
