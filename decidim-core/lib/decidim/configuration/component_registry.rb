# frozen_string_literal: true

module Decidim
  module Configuration
    module ComponentRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a component, usually held in an external library or in a
        # separate folder in the main repository. Exposes a DSL defined by
        # `Decidim::ComponentManifest`.
        #
        # Component manifests are held in a global registry and are used in all kinds of
        # places to figure out what new components or functionalities the component provides.
        #
        # name - A Symbol with the component's unique name.
        #
        # Returns nothing.
        def register_component(name, &)
          component_registry.register(name, &)
        end

        # Public: Stores the registry of components
        def component_registry
          @component_registry ||= ManifestRegistry.new(:components)
        end

        # Public: Finds a component manifest by the component's name.
        #
        # name - The name of the ComponentManifest to find.
        #
        # Returns a ComponentManifest if found, nil otherwise.
        def find_component_manifest(name)
          component_registry.find(name.to_sym)
        end

        # Public: Finds all registered component manifest's via the `register_component`
        # method.
        #
        # Returns an Array[ComponentManifest].
        def component_manifests
          component_registry.manifests.sort_by(&:name)
        end
      end
    end
  end
end
