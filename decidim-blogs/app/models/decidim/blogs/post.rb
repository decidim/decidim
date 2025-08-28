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
      include Decidim::Taxonomizable
      include Decidim::Authorable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Searchable
      include Decidim::Likeable
      include Decidim::Followable
      include Decidim::Reportable
      include Decidim::Publicable
      include Decidim::TranslatableResource
      include Traceable
      include Loggable
      include Decidim::SoftDeletable

      component_manifest_name "blogs"

      translatable_fields :title, :body

      validates :title, presence: true

      scope :created_at_desc, -> { order(arel_table[:created_at].desc) }
      scope :published, -> { where(published_at: ..Time.current) }

      searchable_fields({
                          participatory_space: { component: :participatory_space },
                          A: :title,
                          D: :body,
                          datetime: :created_at
                        },
                        index_on_create: true,
                        index_on_update: ->(post) { post.visible? })

      class << self
        def all_timestamp_attributes_in_model
          super + ["published_at"]
        end

        def log_presenter_class_for(_log)
          Decidim::Blogs::AdminLog::PostPresenter
        end
      end

      # Returns the presenter for this BlogPost, to be used in the views.
      # Required by ResourceRenderer.
      def presenter
        Decidim::Blogs::PostPresenter.new(self)
      end

      def visible?
        participatory_space.try(:visible?) && component.try(:published?) && published?
      end

      def published?
        super && published_at <= Time.current
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
        author.is_a?(Decidim::Organization)
      end

      def users_to_notify_on_comment_created
        followers
      end

      def attachment_context
        :admin
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:title, :body]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [author.name]
      end
    end
  end
end
