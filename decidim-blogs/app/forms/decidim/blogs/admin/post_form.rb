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

        validates :title, translatable_presence: true
        validates :body, translatable_presence: true

        def map_model(post)
          self.user_group_id = post.author.id if post.author.is_a?(Decidim::UserGroup)
          self.user_group_id = "current_organization" if post.author.is_a?(Decidim::Organization)
          self.user_group_id = "current_user" if post.author.is_a?(Decidim::User)
        end

        def user_group
          @user_group ||= Decidim::UserGroup.find_by(
            organization: current_organization,
            id: user_group_id.to_i
          )
        end

        def author
          return current_organization if user_group_id == "current_organization"

          user_group || current_user
        end
      end
    end
  end
end
