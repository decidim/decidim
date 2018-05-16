# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the logic needed to hold and register resource manifests.
  # Intended to be used internally by the ComponentManifest and the
  # ParticipatorySpaceManifest.
  module HasResourceManifests
    extend ActiveSupport::Concern

    included do
      # Public: Finds all the registered resource manifest's via the
      # `register_resource` method.
      #
      # Returns an Array[ResourceManifest].
      def resource_manifests
        @resource_manifests ||= []
      end

      # Public: Registers a resource inside a component manifest. Exposes a DSL
      # defined by `Decidim::ResourceManifest`.
      #
      # Resource manifests are a way to expose a resource from one engine to
      # the whole system. This way resources can be linked between them.
      #
      # block - A Block that will be called to set the Resource attributes.
      #
      # Returns nothing.
      def register_resource
        manifest = ResourceManifest.new
        manifest.component_manifest = self
        yield(manifest)
        manifest.validate!
        resource_manifests << manifest
      end
    end
  end
end
