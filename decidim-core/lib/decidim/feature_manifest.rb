require "decidim/component_manifest"

module Decidim
  class FeatureManifest
    attr_reader :name, :components

    def initialize(name)
      @name = name.to_sym
      @components = Set.new
    end

    def component(name)
      component = ComponentManifest.new(name)
      yield(component)
      @components << component
    end
  end
end
