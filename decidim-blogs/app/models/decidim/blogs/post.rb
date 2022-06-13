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
      include Decidim::Comments::CommentableWithComponent
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

      searchable_fields({
                          participatory_space: { component: :participatory_space },
                          A: :title,
                          D: :body,
                          datetime: :created_at
                        },
                        index_on_create: true,
                        index_on_update: ->(post) { post.visible? })

      def visible?
        participatory_space.try(:visible?) && component.try(:published?)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Blogs::AdminLog::PostPresenter
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        true
      end

      def official?
        author.nil?
      end

      def users_to_notify_on_comment_created
        followers
      end

      def attachment_context
        :admin
      end
    end
  end
end
