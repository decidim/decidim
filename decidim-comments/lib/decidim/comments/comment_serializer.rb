# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Serializes a comment
      def serialize
        {
          id: resource.id,
          created_at: resource.created_at,
          body: resource.body,
          author: {
            id: resource.author.id,
            name: resource.author.name
          },
          alignment: resource.alignment,
          depth: resource.depth,
          user_group: {
            id: resource.user_group.try(:id),
            name: resource.user_group.try(:name)
          },
          commentable_id: resource.decidim_commentable_id,
          commentable_type: resource.decidim_commentable_type,
          root_commentable_url: root_commentable_url
        }
      end

      private

      def root_commentable_url
        decidim_resource_url(root_commentable)
      end

      def root_commentable
        @root_commentable ||= resource.root_commentable
      end

      def feature
        @feature ||= root_commentable.feature
      end

      def participatory_process
        @participatory_process ||= feature.participatory_process
      end

      def organization
        @organization ||= participatory_process.organization
      end
    end
  end
end
