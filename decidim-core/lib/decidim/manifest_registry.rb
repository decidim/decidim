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
      manifests.find { |manifest| manifest.name == name }
    end

    def resource_manifests
      @resource_manifests ||= manifests.flat_map(&:resource_manifests)
    end

    def find_resource_manifest(resource_name_or_klass)
      resource_manifests.find do |manifest|
        manifest.model_class == resource_name_or_klass || manifest.name.to_s == resource_name_or_klass.to_s
      end
    end

    private

    def manifest_class
      "Decidim::#{@entity.to_s.classify}Manifest".constantize
    end
  end
end
