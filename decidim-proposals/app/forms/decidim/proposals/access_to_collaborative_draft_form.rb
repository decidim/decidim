# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object common to accept and reject actions requesters of Collaborative Drafts.
    class AccessToCollaborativeDraftForm < Decidim::Form
      mimic :collaborative_draft

      attribute :id, String
      attribute :requester_user_id, String
      attribute :state, String

      validates :id, :requester_user_id, presence: true
      validates :state, presence: true, inclusion: { in: %w(open) }

      validate :existence_of_requester_in_requesters

      def collaborative_draft
        @collaborative_draft ||= Decidim::Proposals::CollaborativeDraft.find id if id
      end

      def requester_user
        @requester_user ||= Decidim::User.find_by(id: requester_user_id, organization: current_organization) if requester_user_id
      end

      private

      def existence_of_requester_in_requesters
        errors.add(:requester_user_id, :invalid) if collaborative_draft && !collaborative_draft.requesters.exists?(requester_user_id)
      end
    end
  end
end
