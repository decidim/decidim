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
    attribute :component_manifests, Array[ComponentManifest], default: []

    validates :name, presence: true

    # Public: Registers a component to this feature via the DSL provided by
    # ComponentManifest.
    #
    # name - A Symbol with the name of the component to register.
    #
    # Returns nothing.
    def component(name)
      manifest = ComponentManifest.new(name: name.to_sym)
      yield(manifest) if block_given?
      manifest.validate!
      component_manifests << manifest
    end

    # Public: A block that gets called when seeding for this feature takes place.
    #
    # Returns nothing.
    def seeds(&block)
      @seeds = block
    end

    # Public: Creates the seeds for this features in order to populate the database.
    #
    # Returns nothing.
    def seed!
      @seeds&.call
    end
  end
end
