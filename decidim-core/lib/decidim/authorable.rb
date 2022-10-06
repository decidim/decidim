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

      scope :with_official_origin, lambda {
        where(decidim_author_type: "Decidim::Organization")
      }

      scope :with_user_group_origin, lambda {
        where(decidim_author_type: "Decidim::UserBaseEntity")
          .where.not(decidim_user_group_id: nil)
      }

      scope :with_participants_origin, lambda {
        where(decidim_author_type: "Decidim::UserBaseEntity")
          .where(decidim_user_group_id: nil)
      }

      scope :with_any_origin, lambda { |*origin_keys|
        search_values = origin_keys.compact.compact_blank

        conditions = [:official, :participants, :user_group].map do |key|
          search_values.member?(key.to_s) ? try("with_#{key}_origin") : nil
        end.compact
        return self unless conditions.any?

        scoped_query = where(id: conditions.shift)
        conditions.each do |condition|
          scoped_query = scoped_query.or(where(id: condition))
        end

        scoped_query
      }

      validate :verified_user_group, :user_group_membership
      validate :author_belongs_to_organization

      # Checks whether the user is author of the given resource, either directly
      # authoring it or via a user group.
      #
      # user - the user to check for authorship
      def authored_by?(other_author)
        other_author == author || (other_author.respond_to?(:user_groups) && other_author.user_groups.include?(user_group))
      end

      # Returns the normalized author, whether it's a user group or a user. Ideally this should be
      # the *author* method, but it's pending a refactor.
      #
      # Returns an Author, a UserGroup or nil.
      def normalized_author
        user_group || author
      end

      # Public: Checks whether the resource is official or not.
      #
      # Returns a boolean.
      def official?
        decidim_author_type == Decidim::Organization.name
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

        errors.add(:author, :invalid) unless author == organization || (author.respond_to?(:organization) && author.organization == organization)
      end
    end
  end
end
