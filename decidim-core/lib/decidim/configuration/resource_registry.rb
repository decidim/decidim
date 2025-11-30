# frozen_string_literal: true

module Decidim
  module Configuration
    module ResourceRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a resource.
        #
        # Returns nothing.
        def register_resource(name, &)
          resource_registry.register(name, &)
        end

        # Public: Finds a resource manifest by the resource's name.
        #
        # resource_name_or_class - The String of the ResourceManifest name or the class of
        # the ResourceManifest model_class to find.
        #
        # Returns a ResourceManifest if found, nil otherwise.
        def find_resource_manifest(resource_name_or_klass)
          resource_registry.find(resource_name_or_klass)
        end

        # Public: Stores the registry of resource spaces
        def resource_registry
          @resource_registry ||= ManifestRegistry.new(:resources)
        end

        # Public: Finds all registered resource manifests via the `register_component`
        # method.
        #
        # Returns an Array[ResourceManifest].
        def resource_manifests
          resource_registry.manifests
        end
      end
    end
  end
end
