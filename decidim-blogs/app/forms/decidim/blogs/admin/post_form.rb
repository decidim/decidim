# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PostForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :body, String

        attribute :user_group_id, String
        attribute :original_author

        validates :title, translatable_presence: true
        validates :body, translatable_presence: true

        def map_model(post)
          self.user_group_id = case post.author
                               when Decidim::UserGroup
                                 post.author.id
                               when Decidim::Organization
                                 "current_organization"
                               when Decidim::User
                                 post.author&.id == current_user.id ? "current_user" : "original_author"
                               end
          self.original_author = post.author
        end

        def user_group
          @user_group ||= Decidim::UserGroup.find_by(
            organization: current_organization,
            id: user_group_id.to_i
          )
        end

        def author
          return current_organization if user_group_id == "current_organization"
          return original_author if user_group_id == "original_author"

          user_group || current_user
        end
      end
    end
  end
end
