# frozen_string_literal: true

module Decidim
  module Comments
    module Export
      # Public: Given a resource class and a component, returns the comments for that
      # resource in that component.
      #
      # resource_class - The resource's Class
      # component        - The component where the resource is scoped to.
      #
      # Returns an Arel::Relation with all the comments for that component and resource.
      def comments_for_resource(resource_class, component)
        Comment
          .where(decidim_root_commentable_id: resource_class.where(component:))
          .where(decidim_root_commentable_type: resource_class.to_s)
      end

      module_function :comments_for_resource
    end
  end
end
