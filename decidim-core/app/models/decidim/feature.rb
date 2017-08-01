# frozen_string_literal: true

module Decidim
  # A Feature represents a self-contained group of functionalities usually
  # defined via a FeatureManifest. It's meant to be able to provide a single
  # feature that spans over several steps.
  class Feature < ApplicationRecord
    include HasSettings
    include Publicable

    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id"
    has_one :organization, through: :participatory_process
    has_many :categories, through: :participatory_process
    has_many :scopes, through: :organization

    default_scope { order(arel_table[:weight].asc) }

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

    # Public: Returns the value of the registered primary stat.
    def primary_stat
      @primary_stat ||= manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.last
    end
  end
end
