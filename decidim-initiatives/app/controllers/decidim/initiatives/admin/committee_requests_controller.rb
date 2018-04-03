# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller in charge of managing committee membership
      class CommitteeRequestsController < Decidim::Admin::ApplicationController
        include InitiativeAdmin

        # GET /admin/initiatives/:initiative_id/committee_requests
        def index
          authorize! :index, InitiativesCommitteeMember
        end

        # GET /initiatives/:initiative_id/committee_requests/:id/approve
        def approve
          authorize! :approve, membership_request
          membership_request.accepted!

          redirect_to initiative_committee_requests_path(membership_request.initiative)
        end

        # DELETE /initiatives/:initiative_id/committee_requests/:id/revoke
        def revoke
          authorize! :revoke, membership_request
          membership_request.rejected!
          redirect_to initiative_committee_requests_path(membership_request.initiative)
        end

        private

        def membership_request
          @membership_request ||= InitiativesCommitteeMember.find(params[:id])
        end
      end
    end
  end
end
