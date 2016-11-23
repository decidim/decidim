require "decidim/component_manifest"

module Decidim
  class FeatureManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :components, Array[ComponentManifest], default: []

    validates :name, presence: true

    def component(name)
      component = ComponentManifest.new(name: name)
      yield(component) if block_given?
      component.validate!
      components << component
    end
  end
end
