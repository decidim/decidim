# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Proposals versions so users can see how a Proposal/CollaborativeDraft
    # has been updated through time.
    class VersionsController < Decidim::Proposals::ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        @versioned_resource ||=
          if params[:proposal_id]
            present(Proposal.not_hidden.published.where(component: current_component).find(params[:proposal_id]))
          else
            CollaborativeDraft.where(component: current_component).find(params[:collaborative_draft_id])
          end
      end
    end
  end
end
