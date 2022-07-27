# frozen_string_literal: true

module Decidim
  # This query finds the published components for all public participatory
  # spaces in the given organization. Can filter by manifest name.
  class PublicComponents < Decidim::Query
    def self.for(organization, manifest_name: nil)
      new(organization, manifest_name:).query
    end

    def initialize(organization, manifest_name: nil)
      @organization = organization
      @manifest_name = manifest_name
    end

    def query
      results = Decidim::Component.where(participatory_space: public_spaces).published
      results = results.where(manifest_name:) if manifest_name.present?
      results
    end

    private

    attr_reader :organization, :manifest_name

    def public_spaces
      Decidim.participatory_space_manifests.flat_map do |manifest|
        manifest.participatory_spaces.call(organization).public_spaces
      end
    end
  end
end
