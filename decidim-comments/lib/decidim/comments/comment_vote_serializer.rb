# frozen_string_literal: true

module Decidim
  module Comments
    class CommentVoteSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Serializes a comment
      def serialize
        {
          id: resource.id,
          weight: resource.weight,
          comment: {
            id: resource.comment.id,
            created_at: resource.comment.created_at,
            body: resource.comment.body,
            author: {
              id: resource.comment.author.id,
              name: resource.comment.author.name
            },
            alignment: resource.comment.alignment,
            depth: resource.comment.depth,
            user_group: {
              id: resource.comment.user_group.try(:id),
              name: resource.comment.user_group.try(:name)
            },
            commentable_id: resource.comment.decidim_commentable_id,
            commentable_type: resource.comment.decidim_commentable_type,
            root_commentable_url: root_commentable_url

          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end

      private

      def root_commentable_url
        @root_commentable_url ||= if resource.comment.root_commentable.respond_to?(:polymorphic_resource_url)
                                    resource.comment.root_commentable.polymorphic_resource_url
                                  else
                                    ResourceLocatorPresenter.new(resource.comment.root_commentable).url
                                  end
      end
    end
  end
end
