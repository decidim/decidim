module Decidim
  module Comments
    module Export
      # Public: Given a resource class and a feature, returns the comments for that
      # resource in that feature.
      #
      # resource_class - The resource's Class
      # feature        - The feature where the resource is scoped to.
      #
      # Returns an Arel::Relation with all the comments for that feature and resource.
      def comments_for_resource(resource_class, feature)
        Comment
          .where(decidim_root_commentable_id: resource_class.where(feature: feature))
          .where(decidim_root_commentable_type: resource_class.to_s)
      end

      module_function :comments_for_resource
    end
  end
end
