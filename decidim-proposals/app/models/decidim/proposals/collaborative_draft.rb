# frozen_string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraft < ApplicationRecord
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

      has_and_belongs_to_many :access_requestors, class_name: "Decidim::User", join_table: "decidim_proposals_collaborative_draft_access_requests", association_foreign_key: "decidim_user_id", foreign_key: "decidim_proposals_collaborative_draft_id"

      scope :open, -> { where(state: "open") }
      scope :closed, -> { where(state: "closed") }
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

      def closed?
        state == "closed"
      end

      def published?
        state == "published"
      end

    end
  end
end
