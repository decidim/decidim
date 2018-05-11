# frozen_string_literal: true

module Decidim
  #
  # This concern contains the logic related to the access to the resource manifest.
  #
  # Mostly syntactic sugar, but also an alternative to the lack of related documentation.
  #
  module DeclaresResourceManifest
    extend ActiveSupport::Concern

    included do

      # Returns the manifest for the current resource.
      # This is the manifest for the model where this module has been included.
      def resource_manifest
        self_resource_name= self.class.name.demodulize.underscore.pluralize.to_sym
        component.manifest.resource_manifests.find { |m| m.name == self_resource_name }
      end

      def resource_cell
        resource_manifest&.card
      end
    end
  end
end
