# frozen_string_literal: true

module Decidim
  # A Feature represents a self-contained group of functionalities usually
  # defined via a FeatureManifest. It's meant to be able to provide a single
  # feature that spans over several steps.
  class Feature < ApplicationRecord
    include HasSettings

    belongs_to :featurable, polymorphic: true

    default_scope { order(arel_table[:weight].asc) }

    delegate :organization, :categories, to: :featurable
    delegate :scopes, to: :organization

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

    # Public: Finds out whether this feature is published.
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

    # Public: Returns the value of the registered primary stat.
    def primary_stat
      @primary_stat ||= manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.last
    end
  end
end
