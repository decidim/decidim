# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Collaborative Draft Request actions for collaboration between
    # participants on a resource.
    class CollaborativeDraftCollaboratorRequestsController < Decidim::Proposals::CollaborativeDraftsController
      before_action :retrieve_collaborative_draft, only: [:request_access, :request_accept, :request_reject]

      def request_access
        @request_access_form = form(RequestAccessToCollaborativeDraftForm).from_params(params)
        RequestAccessToCollaborativeDraft.call(@request_access_form, current_user) do
          on(:ok) do |_collaborative_draft|
            flash[:notice] = t("access_requested.success", scope: "decidim.proposals.collaborative_drafts.requests")
          end

          on(:invalid) do
            flash[:alert] = t("access_requested.error", scope: "decidim.proposals.collaborative_drafts.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@collaborative_draft).path
      end

      def request_accept
        @accept_request_form = form(AcceptAccessToCollaborativeDraftForm).from_params(params)
        AcceptAccessToCollaborativeDraft.call(@accept_request_form, current_user) do
          on(:ok) do |requester_user|
            flash[:notice] = t("accepted_request.success", scope: "decidim.proposals.collaborative_drafts.requests", user: requester_user.nickname)
          end

          on(:invalid) do
            flash[:alert] = t("accepted_request.error", scope: "decidim.proposals.collaborative_drafts.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@collaborative_draft).path
      end

      def request_reject
        @reject_request_form = form(RejectAccessToCollaborativeDraftForm).from_params(params)
        RejectAccessToCollaborativeDraft.call(@reject_request_form, current_user) do
          on(:ok) do |requester_user|
            flash[:notice] = t("rejected_request.success", scope: "decidim.proposals.collaborative_drafts.requests", user: requester_user.nickname)
          end

          on(:invalid) do
            flash.now[:alert] = t("rejected_request.error", scope: "decidim.proposals.collaborative_drafts.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@collaborative_draft).path
      end
    end
  end
end
