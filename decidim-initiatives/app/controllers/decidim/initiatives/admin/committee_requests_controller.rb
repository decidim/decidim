# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller in charge of managing committee membership
      class CommitteeRequestsController < Decidim::Initiatives::Admin::ApplicationController
        include InitiativeAdmin

        # GET /admin/initiatives/:initiative_id/committee_requests
        def index
          enforce_permission_to :index, :initiative_committee_member
        end

        # GET /initiatives/:initiative_id/committee_requests/:id/approve
        def approve
          enforce_permission_to :approve, :initiative_committee_member, request: membership_request

          ApproveMembershipRequest.call(membership_request) do
            on(:ok) do
              redirect_to edit_initiative_path(current_initiative), flash: {
                notice: I18n.t("success", scope: "decidim.initiatives.committee_requests.approve")
              }
            end
          end
        end

        # DELETE /initiatives/:initiative_id/committee_requests/:id/revoke
        def revoke
          enforce_permission_to :revoke, :initiative_committee_member, request: membership_request

          RevokeMembershipRequest.call(membership_request) do
            on(:ok) do
              redirect_to edit_initiative_path(current_initiative), flash: {
                notice: I18n.t("success", scope: "decidim.initiatives.committee_requests.revoke")
              }
            end
          end
        end

        private

        def membership_request
          @membership_request ||= InitiativesCommitteeMember.find(params[:id])
        end
      end
    end
  end
end
