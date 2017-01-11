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
      manifest.configuration(:global).schema.new(
        self[:configuration].try(:[], "global")
      )
    end

    def configuration=(data)
      self[:configuration] ||= {}

      self[:configuration]["global"] = if data.is_a?(Hash)
                                         manifest.configuration(:global).schema.new(
                                           data
                                         )
                                       elsif data.nil?
                                         {}
                                       else
                                         data.attributes
                                       end
    end

    def step_configurations
      participatory_process.steps.inject({}) do |result, step|
        configuration = manifest.configuration(:step).schema.new(
          self[:configuration].try(:[], step.id.to_s)
        )

        result.merge(step.id.to_s => configuration)
      end
    end

    def step_configurations=(data)
      self[:configuration] ||= {}

      data.each do |key, value|
        self[:configuration][key.to_s] = if value.is_a?(Hash)
                                           manifest.configuration(:step).schema.new(value)
                                         elsif value.nil?
                                           {}
                                         else
                                           value.attributes
                                         end
      end
    end
  end
end
