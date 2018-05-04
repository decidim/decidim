# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to collective or shared authorship.
  #
  # Coauthorable shares nearly the same object interface as Authorable but with some differences.
  # - `authored_by?(user)` is exactly the same
  # - `normalized_authors` is pluralized
  #
  # All coauthors, including the initial author, will share the same permissions.
  module Coauthorable
    extend ActiveSupport::Concern

    included do
      has_many :authors, class_name: "Decidim::User"
      has_many :user_groups, class_name: "Decidim::UserGroup"

      # Checks whether the user is author of the given proposal, either directly
      # authoring it or via a user group.
      #
      # user - the user to check for authorship
      def authored_by?(user)
        author == user || user.user_groups.include?(user_group)
      end

      # Returns the normalized author, whether it's a user group or a user. Ideally this should be
      # the *author* method, but it's pending a refactor.
      #
      # Returns an Author, a UserGroup or nil.
      def normalized_authors
        user_group || author
      end
    end
  end
end
