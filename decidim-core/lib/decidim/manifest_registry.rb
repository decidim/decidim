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
      manifests.find do |manifest|
        manifest.try(:model_class_name) == name.to_s ||
          manifest.name.to_s == name.to_s ||
          manifest.name.to_s.pluralize == name.to_s
      end
    end

    private

    def manifest_class
      "Decidim::#{@entity.to_s.classify}Manifest".constantize
    end
  end
end
