# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be able to create
  # links from it to another resource.
  module Resourceable
    extend ActiveSupport::Concern

    included do
      # An association with all the links that point to this model.
      has_many :resource_links_to, as: :to, class_name: "Decidim::ResourceLink"

      # An association with all the links that are originated from this model.
      has_many :resource_links_from, as: :from, class_name: "Decidim::ResourceLink"

      # Finds all the linked resources to or from this model for a given resource
      # name and link name.
      #
      # resource_name - The String name of the resource manifest exposed by a feature.
      # link_name     - The String name of the link between this model and the target resource.
      #
      # Returns an ActiveRecord::Relation.
      def linked_resources(resource_name, link_name)
        scope = sibling_scope(resource_name)

        from = scope
               .joins(:resource_links_from)
               .where(decidim_resource_links: { name: link_name, to_id: id, to_type: self.class.name })

        to = scope
             .joins(:resource_links_to)
             .where(decidim_resource_links: { name: link_name, from_id: id, from_type: self.class.name })

        scope.where(id: from).or(scope.where(id: to))
      end

      # Builds an ActiveRecord::Relation in order to load all the resources
      # that are in the same parent as this model.
      #
      # resource_name - The String name of the resource manifest exposed by a feature.
      #
      # Returns an ActiveRecord::Relation.
      def sibling_scope(resource_name)
        manifest = Decidim.find_resource_manifest(resource_name)
        return self.class.none unless manifest

        scope = manifest.resource_scope(feature)
        scope = scope.where("#{self.class.table_name}.id != ?", id) if manifest.model_class == self.class

        scope
      end

      # Links the given resources to this model, replaces any previous links with the same name.
      #
      # resources - An Array or ActiveRecord::Base object to link to.
      # link_name - The String name to use as the name between the resources.
      # data      - An optional Hash to add to the link.
      #
      # Returns nothing.
      def link_resources(resources, link_name, data = {})
        transaction do
          resource_links_from.where(name: link_name).delete_all
          Array.wrap(resources).each do |resource|
            Decidim::ResourceLink.create!(
              from: self,
              to: resource,
              name: link_name,
              data: data
            )
          end
        end
      end
    end

    class_methods do
      # Finds the name of the classes that have been linked to this model for the given
      # `feature`.
      #
      # feature - a Decidim::Feature instance where the links will be scoped to.
      #
      # Returns an Array of Strings.
      def linked_classes_for(feature)
        scope = where(feature: feature)

        from = scope
               .joins(:resource_links_from)
               .where(decidim_resource_links: { from_type: name })

        to = scope
             .joins(:resource_links_to)
             .where(decidim_resource_links: { to_type: name })

        ResourceLink
          .where(from: from)
          .or(ResourceLink.where(to: to))
          .pluck(:from_type, :to_type)
          .flatten
          .uniq
          .reject { |k| k == name }
      end

      # Finds the resource manifest for the model.
      #
      # Returns a Decidim::ResourceManifest
      def resource_manifest
        Decidim.find_resource_manifest(self)
      end
    end
  end
end
