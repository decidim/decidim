require "decidim/component_manifest"

module Decidim
  class FeatureManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :components, Array[ComponentManifest], default: []

    validates :name, presence: true

    def configuration
      @configuration ||= Configuration.new
      yield(@configuration) if block_given?
      @configuration
    end

    def component(name)
      component = ComponentManifest.new(name: name)
      yield(component)
      component.validate!
      components << component
    end
  end
end
