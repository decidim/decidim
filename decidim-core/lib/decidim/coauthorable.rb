# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to collective or shared authorship.
  #
  # Coauthorable shares nearly the same object interface as Authorable but with some differences.
  # - `authored_by?(user)` is exactly the same
  # - `normalized_author` is now `identities`.
  #
  # All coauthors, including the initial author, will share the same permissions.
  module Coauthorable
    extend ActiveSupport::Concern

    included do
      has_many :coauthorships, as: :coauthorable, class_name: "Decidim::Coauthorship", dependent: :destroy
      has_many :authors, through: :coauthorships, class_name: "Decidim::User"
      has_many :user_groups, as: :coauthorable, class_name: "Decidim::UserGroup", through: :coauthorships

      # retrieves models from all identities of the user.
      scope :from_all_user_identities, ->(user) { joins(:coauthorships).where("decidim_coauthorships.decidim_author_id": user.id) }
      # retrieves models from the given User, ignoring the UserGroups it belongs to.
      scope :from_author, ->(author) { joins(:coauthorships).where("decidim_coauthorships.decidim_author_id": author.id).where("decidim_coauthorships.decidim_user_group_id": nil) }
      # retrieves models from the given UserGroup.
      scope :from_user_group, ->(user_group) { joins(:coauthorships).where("decidim_coauthorships.decidim_user_group_id": user_group.id) }

      # Checks whether the user is author of the given proposal, either directly
      # authoring it or via a user group.
      #
      # user - the user to check for authorship
      def authored_by?(user)
        coauthorships.where(author: user).or(coauthorships.where(user_group: user.user_groups)).exists?
      end

      # Returns the identities for the authors, whether they are user groups or users.
      #
      # Returns an Array of User and/or UserGroups.
      def identities
        coauthorships.order(:created_at).collect(&:identity)
      end

      # Syntactic sugar to access first coauthor
      def creator_author
        authors.first
      end

      # Syntactic sugar to access first coauthor
      def creator_user_group
        user_groups.first
      end

      # Syntactic sugar to access first identity whether it is a User or a UserGroup.
      def creator_identity
        coauthorships.order(:created_at).first&.identity
      end

      # Adds a new coauthor to the list of coauthors. The coauthorship is created with
      # current object as coauthorable and `user` param as author. To set the user group
      # use `extra_attrs` either with `user_group` or `decidim_user_group_id` keys.
      #
      # @param user: The new coauthor.
      # @extra_attrs: Extra
      def add_coauthor(user, extra_attrs = {})
        attrs = { coauthorable: self, author: user }
        Decidim::Coauthorship.create!(attrs.merge(extra_attrs))
      end
    end
  end
end
