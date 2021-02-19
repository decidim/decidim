# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PostForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :body, String

        attribute :user_group_id, Integer

        validates :title, translatable_presence: true
        validates :body, translatable_presence: true

        def user_group
          @user_group ||= Decidim::UserGroup.find_by(
            organization: current_organization,
            id: user_group_id.to_i
          )
        end
      end
    end
  end
end
