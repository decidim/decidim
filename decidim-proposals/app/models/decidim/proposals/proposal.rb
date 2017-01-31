# frozen_string_literal: true
module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Authorable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory

      feature_manifest_name "proposals"

      has_many :votes, foreign_key: "decidim_proposal_id", class_name: ProposalVote, dependent: :destroy

      validates :title, :body, presence: true

      def author_name
        user_group&.name || author&.name || I18n.t("decidim.proposals.models.proposal.fields.official_proposal")
      end

      def author_avatar_url
        author&.avatar&.url || ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      # Public: Check if the user has voted the proposal
      #
      # Returns Boolean
      def voted_by?(user)
        votes.any? { |vote| vote.author == user }
      end
    end
  end
end
