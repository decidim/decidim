# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when Collaborative Draft editors accept a request to acces it.
    class AcceptAccessToCollaborativeDraftForm < Decidim::Form
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
        @requester_user ||= Decidim::User.find requester_user_id if requester_user_id
      end

      private

      def existence_of_requester_in_requesters
        if collaborative_draft
          errors.add(:requester_user_id, :invalid) unless collaborative_draft.requesters.exists? requester_user_id
        end
      end
    end
  end
end
