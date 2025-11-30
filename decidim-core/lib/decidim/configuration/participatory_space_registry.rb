# frozen_string_literal: true

module Decidim
  module Configuration
    module ParticipatorySpaceRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a participatory space, usually held in an external library
        # or in a separate folder in the main repository. Exposes a DSL defined by
        # `Decidim::ParticipatorySpaceManifest`.
        #
        # Participatory space manifests are held in a global registry and are used in
        # all kinds of places to figure out what new components or functionalities the
        # participatory space provides.
        #
        # name - A Symbol with the participatory space's unique name.
        #
        # Returns nothing.
        def register_participatory_space(name, &)
          participatory_space_registry.register(name, &)
        end

        # Public: Finds a participatory space manifest by the participatory space's
        # name.
        #
        # name - The name of the ParticipatorySpaceManifest to find.
        #
        # Returns a ParticipatorySpaceManifest if found, nil otherwise.
        def find_participatory_space_manifest(name)
          participatory_space_registry.find(name.to_sym)
        end

        # Public: Stores the registry of participatory spaces
        def participatory_space_registry
          @participatory_space_registry ||= ManifestRegistry.new(:participatory_spaces)
        end

        # Public: Finds all registered participatory space manifest's via the
        # `register_participatory_space` method.
        #
        # Returns an Array[ParticipatorySpaceManifest].
        def participatory_space_manifests
          participatory_space_registry.manifests
        end
      end
    end
  end
end
