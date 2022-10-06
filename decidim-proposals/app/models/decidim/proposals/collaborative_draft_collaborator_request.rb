# frozen_string_literal: true

module Decidim
  module Proposals
    # A collaborative_draft can accept requests to coauthor and contribute
    class CollaborativeDraftCollaboratorRequest < Proposals::ApplicationRecord
      belongs_to :collaborative_draft, class_name: "Decidim::Proposals::CollaborativeDraft", foreign_key: :decidim_proposals_collaborative_draft_id
      belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    end
  end
end
