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
  end
end
