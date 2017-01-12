# frozen_string_literal: true
module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
      belongs_to :author, foreign_key: "decidim_author_id", class_name: Decidim::User
      belongs_to :category, foreign_key: "decidim_category_id", class_name: Decidim::Category
      belongs_to :scope, foreign_key: "decidim_scope_id", class_name: Decidim::Scope
      has_one :organization, through: :feature
      has_many :votes, foreign_key: "decidim_proposal_id", class_name: ProposalVote, dependent: :destroy

      validates :title, :feature, :body, presence: true
      validate :category_belongs_to_feature
      validate :scope_belongs_to_organization
      validate :author_belongs_to_organization

      def author_name
        author&.name || I18n.t("decidim.proposals.models.proposal.fields.official_proposal")
      end

      def author_avatar_url
        author&.avatar&.url || ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      # Public: Canpeople comment on this proposal?
      #
      # Until we have a way to store options fore features and its resources we
      # assume all proposals can be commented.
      #
      # Returns Boolean
      def commentable?
        true
      end

      # Public: Check if the user has voted the proposal
      #
      # Returns Boolean
      def voted_by?(user)
        votes.any? { |vote| vote.author == user }
      end

      private

      def category_belongs_to_feature
        return unless category
        errors.add(:category, :invalid) unless feature.categories.where(id: category.id).exists?
      end

      def scope_belongs_to_organization
        return unless scope
        errors.add(:scope, :invalid) unless feature.scopes.where(id: scope.id).exists?
      end

      def author_belongs_to_organization
        return unless author
        errors.add(:author, :invalid) unless Decidim::User.where(decidim_organization_id: feature.organization.id, id: author.id).exists?
      end
    end
  end
end
