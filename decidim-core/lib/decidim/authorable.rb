# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to single authorship.
  #
  # Sometimes authorship may belong to a single user or be shared among coauthors, in
  # this latest case the Coauthorable concern should be used instead of Authorable.
  module Authorable
    extend ActiveSupport::Concern

    included do
      belongs_to :author, polymorphic: true, foreign_key: "decidim_author_id", foreign_type: "decidim_author_type"
      belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true

      validates :author, presence: true
      validate :verified_user_group, :user_group_membership
      validate :author_belongs_to_organization

      # Checks whether the user is author of the given resource, either directly
      # authoring it or via a user group.
      #
      # user - the user to check for authorship
      def authored_by?(other_author)
        other_author == author || other_author.respond_to?(:user_groups) && other_author.user_groups.include?(user_group)
      end

      # Returns the normalized author, whether it's a user group or a user. Ideally this should be
      # the *author* method, but it's pending a refactor.
      #
      # Returns an Author, a UserGroup or nil.
      def normalized_author
        user_group || author
      end

      private

      def verified_user_group
        return unless user_group

        errors.add :user_group, :invalid unless user_group.verified?
      end

      def user_group_membership
        return unless user_group

        errors.add :user_group, :invalid unless user_group.users.include? author
      end

      def author_belongs_to_organization
        return if !author || !organization

        errors.add(:author, :invalid) unless author == organization || author.respond_to?(:organization) && author.organization == organization
      end
    end
  end
end
