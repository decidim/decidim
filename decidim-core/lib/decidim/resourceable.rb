# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be able to create
  # links from it to another resource.
  module Resourceable
    extend ActiveSupport::Concern

    included do
      # An association with all the links that point to this model.
      has_many :resource_links_to, as: :to, class_name: "Decidim::ResourceLink"

      # An association with all the links that are originated from this model.
      has_many :resource_links_from, as: :from, class_name: "Decidim::ResourceLink"

      # An association with the permissions settings for the resource
      has_one :resource_permission, as: :resource, class_name: "Decidim::ResourcePermission"

      # Finds all the linked resources to or from this model for a given resource
      # name and link name.
      #
      # resource_name - The String name of the resource manifest exposed by a component.
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
      # resource_name - The String name of the resource manifest exposed by a component.
      #
      # Returns an ActiveRecord::Relation.
      def sibling_scope(resource_name)
        manifest = Decidim.find_resource_manifest(resource_name)
        return self.class.none unless manifest

        scope = manifest.resource_scope(component)
        scope = scope.where("#{self.class.table_name}.id != ?", id) if manifest.model_class == self.class
        scope.includes(:component).where.not(decidim_components: { published_at: nil })
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
            payload = {
              from_type: self.class.name,
              from_id: id,
              to_type: resource.class.name,
              to_id: resource.id
            }
            event_name = "decidim.resourceable.#{link_name}.created"
            ActiveSupport::Notifications.instrument event_name, this: payload do
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

      delegate :resource_manifest, to: :class

      # Checks throughout all its parent hierarchy if this Resource is visible.
      # i.e. checks
      # - the visibility of its parent Component
      # - the visibility of its participatory space.
      # - the visibility of the resource itself.
      def visible?
        !component.participatory_space.try(:private_space?) && component.published? && resource_visible?
      end

      # Check only the resource visibility not its hierarchy.
      # This method is intended to be overriden by classes that include this module and have the
      # need to impose its own visibility rules.
      #
      # @return If the resource is also Publicable checks if the resource is published, otherwise returns true by default.
      def resource_visible?
        if respond_to?(:published?)
          published?
        else
          true
        end
      end

      # Public: Whether the permissions for this object actions can be set at resource level.
      def allow_resource_permissions?
        false
      end

      # Public: Returns permissions for this object actions if they can be set at resource level.
      def permissions
        resource_permission&.permissions if allow_resource_permissions?
      end
    end

    class_methods do
      # Finds the name of the classes that have been linked to this model for the given
      # `component`.
      #
      # component - a Decidim::Component instance where the links will be scoped to.
      #
      # Returns an Array of Strings.
      def linked_classes_for(component)
        scope = where(component: component)

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
