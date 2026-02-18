# frozen_string_literal: true

module Decidim
  #
  # Takes care of holding and serving globally registered manifests.
  #
  class ManifestRegistry
    def initialize(entity)
      @entity = entity
    end

    def register(name)
      manifest = manifest_class.new(name: name.to_sym)
      yield(manifest)
      manifest.validate!
      manifests << manifest
    end

    def manifests
      @manifests ||= Set.new
    end

    def find(name)
      name = name.to_s
      manifests.find do |manifest|
        manifest_name = manifest.name.to_s
        manifest_name == name ||
          manifest.try(:model_class_name) == name ||
          manifest_name.pluralize == name
      end
    end

    private

    def manifest_class
      "Decidim::#{@entity.to_s.classify}Manifest".safe_constantize || "Decidim::#{@entity.to_s.camelize}Manifest".constantize
    end
  end
end
