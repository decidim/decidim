# frozen_string_literal: true

require "active_support/concern"

module Decidim
  #
  # Including this concern will enable a `register_permissions` class method to
  # be used for configuring the permissions for the includer artifact.
  #
  module RegistersPermissions
    extend ActiveSupport::Concern

    def self.register_permissions(artifact, *permission_classes)
      ::Decidim.permissions_registry.register_permissions(artifact, *permission_classes)
    end

    class_methods do
      # Registers the permissions for the given `artifact`.
      #
      # +artifact+ is expected to be the class or module that declares `NeedsPermission.permission_class_chain`.
      # +permission_classes+ are subclasses of `DefaultPermissions` or at least should quack as one.
      def register_permissions(artifact, *permission_classes)
        RegistersPermissions.register_permissions(artifact, *permission_classes)
      end
    end
  end
end
