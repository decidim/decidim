# frozen_string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraft < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Coauthorable
      include Decidim::HasComponent
      include Decidim::ScopableComponent
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Proposals::CommentableCollaborativeDraft
      include Decidim::Traceable
      include Decidim::Loggable

      has_many :collaborator_requests,
               class_name: "Decidim::Proposals::CollaborativeDraftCollaboratorRequest",
               foreign_key: :decidim_proposals_collaborative_draft_id,
               dependent: :destroy

      has_many :requesters,
               through: :collaborator_requests,
               source: :user,
               class_name: "Decidim::User",
               foreign_key: :decidim_user_id

      scope :open, -> { where(state: "open") }
      scope :withdrawn, -> { where(state: "withdrawn") }
      scope :published, -> { where(state: "published") }

      # Checks whether the user can edit the given proposal.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        authored_by?(user)
      end

      def open?
        state == "open"
      end

      def withdrawn?
        state == "withdrawn"
      end

      def published?
        state == "published"
      end
    end
  end
end
