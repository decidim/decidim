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

      after_save :set_published_at, if: -> { published_at.nil? }

      scope :created_at_desc, -> { order(arel_table[:created_at].desc) }
      scope :published, -> { where("published_at <= ?", Time.current) }

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
        author.is_a?(Decidim::Organization)
      end

      def user_group?
        author.is_a?(Decidim::UserGroup)
      end

      def users_to_notify_on_comment_created
        followers
      end

      def attachment_context
        :admin
      end

      private

      def set_published_at
        update_attribute(:published_at, created_at) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
