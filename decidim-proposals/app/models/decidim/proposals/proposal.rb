# frozen_string_literal: true

module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Authorable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::Comments::Commentable

      feature_manifest_name "proposals"

      has_many :votes, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy, counter_cache: "proposal_votes_count"

      validates :title, :body, presence: true

      geocoded_by :address, http_headers: ->(proposal) { { "Referer" => proposal.feature.organization.host } }

      scope :accepted, -> { where(state: "accepted") }
      scope :rejected, -> { where(state: "rejected") }
      scope :evaluating, -> { where(state: "evaluating") }

      def self.order_randomly(seed)
        transaction do
          connection.execute("SELECT setseed(#{connection.quote(seed)})")
          order("RANDOM()").load
        end
      end

      def author_name
        return I18n.t("decidim.proposals.models.proposal.fields.official_proposal") if official?
        user_group&.name || author.name
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

      # Public: Checks if the organization has marked the proposal as evaluating it.
      #
      # Returns Boolean.
      def evaluating?
        state == "evaluating"
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

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      # Public: Whether the proposal is official or not.
      def official?
        author.nil?
      end

      # Public: Overrides the `notifiable?` Notifiable concern method.
      # When a proposal is commented the proposal's author is notified if it is not the same
      # who has commented the proposal and if the proposal's author has comment notifications enabled.
      def notifiable?(context)
        return true if official?
        context[:author] != author && author.comments_notifications?
      end

      # Public: Overrides the `users_to_notify` Notifiable concern method.
      def users_to_notify
        return feature.participatory_space.admins if official?
        [author]
      end
    end
  end
end
