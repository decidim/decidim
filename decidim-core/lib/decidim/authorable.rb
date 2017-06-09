# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to authorship
  module Authorable
    extend ActiveSupport::Concern

    included do
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User", optional: true
      belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true

      validate :verified_user_group, :user_group_membership
      validate :author_belongs_to_organization

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
        errors.add(:author, :invalid) unless author.organization == organization
      end
    end
  end
end
