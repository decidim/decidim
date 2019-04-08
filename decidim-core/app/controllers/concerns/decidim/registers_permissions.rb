# frozen_string_literal: true

require "active_support/concern"

module Decidim
  #
  # Including this concern will enable a `register_permissions` class method to
  # be used for configuring the permissions for the includer artifact.
  #
  module RegistersPermissions
    extend ActiveSupport::Concern

    class_methods do
      # Registers the of `Permissions` for the given `artifact`.
      #
      # +artifact+ is expected to be the class or module that delcares `NeedsPermission.permission_class_chain`.
      # +permission_classes+ are sublasses of `DefaultPermissions`.
      def register_permissions(artifact, *permission_classes)
        ::Decidim.permissions_registry.register_permissions(artifact, *permission_classes)
      end
    end
  end
end
