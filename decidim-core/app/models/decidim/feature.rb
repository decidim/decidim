# frozen_string_literal: true

module Decidim
  # A Feature represents a self-contained group of functionalities usually
  # defined via a FeatureManifest. It's meant to be able to provide a single
  # feature that spans over several steps.
  class Feature < ApplicationRecord
    include HasSettings
    include Publicable

    belongs_to :participatory_space, polymorphic: true

    default_scope { order(arel_table[:weight].asc) }

    delegate :organization, :categories, to: :participatory_space
    delegate :scopes, to: :organization

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

    # Public: The name of the engine the feature is mounted to.
    def mounted_engine
      "decidim_#{participatory_space_name}_#{manifest_name}"
    end

    # Public: The name of the admin engine the feature is mounted to.
    def mounted_admin_engine
      "decidim_admin_#{participatory_space_name}_#{manifest_name}"
    end

    # Public: The hash of contextual params when the feature is mounted.
    def mounted_params
      {
        host: organization.host,
        feature_id: id,
        "#{participatory_space.underscored_name}_slug".to_sym => participatory_space.slug
      }
    end

    # Public: Returns the value of the registered primary stat.
    def primary_stat
      @primary_stat ||= manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.last
    end

    private

    def participatory_space_name
      participatory_space.underscored_name
    end
  end
end
