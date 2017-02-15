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
      include Decidim::Comments::Commentable

      feature_manifest_name "proposals"

      has_many :votes, foreign_key: "decidim_proposal_id", class_name: ProposalVote, dependent: :destroy, counter_cache: "proposal_votes_count"
      has_many :reports, foreign_key: "decidim_proposal_id", class_name: ProposalReport, dependent: :destroy

      validates :title, :body, presence: true

      scope :accepted, -> { where(state: "accepted") }
      scope :rejected, -> { where(state: "rejected") }

      def author_name
        user_group&.name || author&.name || I18n.t("decidim.proposals.models.proposal.fields.official_proposal")
      end

      def author_avatar_url
        author&.avatar&.url || ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      # Public: Check if the user has voted the proposal.
      #
      # Returns Boolean.
      def voted_by?(user)
        votes.where(author: user).any?
      end

      # Public: Check if the user has reported the proposal.
      #
      # Returns Boolean.
      def reported_by?(user)
        reports.where(user: user).any?
      end

      # Public: Checks if the organization has given an answer for the proposal.
      #
      # Returns Boolean.
      def answered?
        answered_at.present?
      end

      # Public: Checks if the organization has accepted a proposal.
      #
      # Returns Boolean.
      def accepted?
        state == "accepted"
      end

      # Public: Checks if the organization has rejected a proposal.
      #
      # Returns Boolean.
      def rejected?
        state == "rejected"
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
         commentable? && !feature.active_step_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end
    end
  end
end
