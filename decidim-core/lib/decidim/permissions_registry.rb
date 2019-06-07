# frozen_string_literal: true

module Decidim
  #
  # Takes care of holding and accessing permissions classes for each artifact.
  #
  class PermissionsRegistry
    def initialize
      @registry = {}
    end

    # Syntactic sugar for the `chain_for` instance method.
    def self.chain_for(artifact)
      ::Decidim.permissions_registry.chain_for(artifact)
    end

    # Returns the registered array of permissions for the given `artifact`.
    #
    # +artifact+ is expected to be the class or module that declares `NeedsPermission.permission_class_chain`.
    def chain_for(artifact)
      @registry[artifact_to_key(artifact)]
    end

    # Registers the of `Permissions` for the given `artifact`.
    #
    # +artifact+ is expected to be the class or module that declares `NeedsPermission.permission_class_chain`.
    # +permission_classes+ are subclasses of `DefaultPermissions`.
    def register_permissions(artifact, *permission_classes)
      @registry[artifact_to_key(artifact)] = permission_classes.dup
    end

    # Registry accepts the class or the class name of the artifact,
    # but the registry only indexes by the name.
    # Artifact name normalization is done here.
    def artifact_to_key(artifact)
      artifact.respond_to?(:name) ? artifact.name : artifact
    end
  end
end
