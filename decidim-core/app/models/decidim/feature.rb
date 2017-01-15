# frozen_string_literal: true
module Decidim
  # A Feature represents a self-contained group of functionalities usually
  # defined via a FeatureManifest and its Components. It's meant to be able to
  # provide a single feature that spans over several steps, each one with its component.
  class Feature < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id"
    has_one :organization, through: :participatory_process
    has_many :categories, through: :participatory_process
    has_many :scopes, through: :organization

    validates :participatory_process, presence: true

    after_initialize :default_values

    # Public: Finds the manifest this feature is associated to.
    #
    # Returns a FeatureManifest.
    def manifest
      Decidim.find_feature_manifest(manifest_name)
    end

    # Public: Assigns a manifest to this feature.
    #
    # manifest - The FeatureManifest for this Feature.
    #
    # Returns nothing.
    def manifest=(manifest)
      self.manifest_name = manifest.name
    end

    def configuration
      configuration_schema(:global).new(self[:configuration]["global"])
    end

    def configuration=(data)
      self[:configuration]["global"] = serialize_configuration(configuration_schema(:global), data)
    end

    def step_configurations
      participatory_process.steps.each_with_object({}) do |step, result|
        result[step.id.to_s] = configuration_schema(:step).new(self[:configuration].dig("steps", step.id.to_s))
      end
    end

    def step_configurations=(data)
      self[:configuration]["steps"] = data.each_with_object({}) do |(key, value), result|
        result[key.to_s] = serialize_configuration(configuration_schema(:step), value)
      end
    end

    private

    def serialize_configuration(schema, value)
      if value.respond_to?(:attributes)
        value.attributes
      else
        schema.new(value)
      end
    end

    def configuration_schema(name)
      manifest.configuration(name.to_sym).schema
    end

    def default_values
      self[:configuration] ||= {}
    end
  end
end
