# frozen_string_literal: true

module Decidim
  module Blogs
    # This class holds a Form to update pages from Decidim's admin panel.
    class PostForm < Decidim::Form
      include TranslatableAttributes

      attribute :title, String
      attribute :body, String

      attribute :decidim_author_id, Integer

      validates :title, presence: true
      validates :body, presence: true
      validate :can_set_author

      def map_model(model)
        presenter = PostPresenter.new(model)

        self.title = presenter.title
        self.body = presenter.body
      end

      def author
        @author ||= Decidim::UserBaseEntity.find_by(
          organization: current_organization,
          id: decidim_author_id
        )
      end

      private

      def can_set_author
        return if author == current_user
        return if user_groups.include? author
        return if author == post&.author

        errors.add(:decidim_author_id, :invalid)
      end

      def post
        @post ||= Post.find_by(id: id)
      end

      def user_groups
        @user_groups ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      end
    end
  end
end
