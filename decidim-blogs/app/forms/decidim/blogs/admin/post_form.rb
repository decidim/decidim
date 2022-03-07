# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PostForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :body, String

        attribute :decidim_author_id, Integer
        attribute :id, Integer

        validates :title, translatable_presence: true
        validates :body, translatable_presence: true
        validate :can_set_author

        def user_or_group
          @user_or_group ||= Decidim::UserBaseEntity.find_by(
            organization: current_organization,
            id: decidim_author_id
          )
        end

        def author
          user_or_group || current_organization
        end

        private

        def can_set_author
          return if author == current_user.organization
          return if author == current_user

          user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
          return if user_groups.include? author

          post_id = id

          post_author = Post.find(post_id)&.author
          return if author == post_author

          errors.add(:decidim_author_id, :invalid) unless post_author&.organization == current_organization

          errors.add(:decidim_author_id, :invalid)
        end
      end
    end
  end
end
