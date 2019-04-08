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

    # Returns the registered array of `Permissions` for the given `artifact`.
    #
    # +artifact+ is expected to be the class or module that delcares `NeedsPermission.permission_class_chain`.
    def chain_for(artifact)
      @registry[artifact]
    end

    # Registers the of `Permissions` for the given `artifact`.
    #
    # +artifact+ is expected to be the class or module that delcares `NeedsPermission.permission_class_chain`.
    # +permission_classes+ are sublasses of `DefaultPermissions`.
    def register_permissions(artifact, *permission_classes)
      @registry[artifact] = permission_classes.dup
    end
  end
end
