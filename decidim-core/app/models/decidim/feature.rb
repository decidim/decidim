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

    default_scope { order(arel_table[:weight].asc) }

    after_initialize :default_values

    # Public: Filters the features that are published and, therefore, visible by
    # the end user.
    #
    # Returns an ActiveRecord::Relation.
    def self.published
      where.not(published_at: nil)
    end

    # Public: Filters the features that are unpublished and, therefore, not visible
    # by the end user.
    #
    # Returns an ActiveRecord::Relation.
    def self.unpublished
      where(published_at: nil)
    end

    # Public: Finds out wether this feature is published.
    #
    # Returns true if published, false otherwise.
    def published?
      published_at.present?
    end

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

    def settings
      settings_schema(:global).new(self[:settings]["global"])
    end

    def settings=(data)
      self[:settings]["global"] = serialize_settings(settings_schema(:global), data)
    end

    def step_settings
      participatory_process.steps.reload.each_with_object({}) do |step, result|
        result[step.id.to_s] = settings_schema(:step).new(self[:settings].dig("steps", step.id.to_s))
      end
    end

    def step_settings=(data)
      self[:settings]["steps"] = data.each_with_object({}) do |(key, value), result|
        result[key.to_s] = serialize_settings(settings_schema(:step), value)
      end
    end

    def active_step_settings
      active_step = participatory_process.active_step
      return nil unless active_step

      step_settings.fetch(active_step.id.to_s)
    end

    private

    def serialize_settings(schema, value)
      if value.respond_to?(:attributes)
        value.attributes
      else
        schema.new(value)
      end
    end

    def settings_schema(name)
      manifest.settings(name.to_sym).schema
    end

    def default_values
      self[:settings] ||= {}
    end
  end
end
