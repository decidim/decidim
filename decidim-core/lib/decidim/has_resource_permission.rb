# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern to include permission to a resource not related with components
  # od a participatory space.
  module HasResourcePermission
    extend ActiveSupport::Concern

    included do
      # An association with the permissions settings for the resource
      has_one :resource_permission, as: :resource, class_name: "Decidim::ResourcePermission"

      delegate :resource_manifest, :resource_key, to: :class

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
      # Finds the resource manifest for the model.
      #
      # Returns a Decidim::ResourceManifest
      def resource_manifest
        Decidim.find_resource_manifest(self)
      end

      def resource_key
        model_name.param_key
      end
    end
  end
end
