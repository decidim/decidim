# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Serializes a comment
      def serialize
        {
          id: resource.id,
          created_at: resource.created_at,
          body: resource.body.values.first,
          locale: resource.body.keys.first,
          author: {
            id: resource.author.id,
            name: resource.author.name
          },
          alignment: resource.alignment,
          depth: resource.depth,
          commentable_id: resource.decidim_commentable_id,
          commentable_type: resource.decidim_commentable_type,
          root_commentable_url:
        }
      end

      private

      def root_commentable_url
        @root_commentable_url ||= if resource.root_commentable.respond_to?(:polymorphic_resource_url)
                                    resource.root_commentable.polymorphic_resource_url({})
                                  else
                                    ResourceLocatorPresenter.new(resource.root_commentable).url
                                  end
      end
    end
  end
end
