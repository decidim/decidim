module Decidim
  module Comments
    class CommentSerializer < Decidim::Exporters::Serializer
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
          commentable_type: resource.decidim_commentable_type
        }
      end
    end
  end
end
