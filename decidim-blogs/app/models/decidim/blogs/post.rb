# frozen_string_literal: true

module Decidim
  module Blogs
    # The data store for a Blog in the Decidim::Blogs component. It stores a
    # title, description and any other useful information to render a blog.
    class Post < Blogs::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasComponent
      include Decidim::Authorable
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Endorsable
      include Decidim::Followable
      include Decidim::TranslatableResource
      include Traceable
      include Loggable

      component_manifest_name "blogs"

      translatable_fields :title, :body

      validates :title, presence: true

      scope :created_at_desc, -> { order(arel_table[:created_at].desc) }

      searchable_fields(
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :body,
        datetime: :created_at
      )

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !component.current_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      def official?
        author.nil?
      end

      # Public: Whether the object can have new comments or not.
      def user_allowed_to_comment?(user)
        can_participate_in_space?(user)
      end

      def users_to_notify_on_comment_created
        followers
      end
    end
  end
end
