# frozen_string_literal: true
require "decidim/component_manifest"

module Decidim
  # This class handles all the logic associated to configuring a feature
  # associated to a participatory process.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_feature`.
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
