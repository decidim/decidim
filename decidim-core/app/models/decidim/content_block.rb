# frozen_string_literal: true

module Decidim
  # this class represents a content block manifest instance in the DB. Check the
  # docs on `ContentBlockRegistry` and `ContentBlockManifest` for more info.
  class ContentBlock < ApplicationRecord
    # We're tricking the attachments system, as we need to give a name to each
    # attachment (image names are defined in the content block manifest), but the
    # current attachments do not allow this, so we'll use the attachment `title`
    # field to identify each image.
    include HasAttachments
    include Publicable

    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

    # Public: finds the published content blocks for the given scope and
    # organization. Returns them ordered by ascending weight (lowest first).
    def self.for_scope(scope, organization:)
      where(organization: organization, scope: scope)
        .order(weight: :asc)
    end

    def manifest
      @manifest ||= Decidim.content_blocks.for(scope).find { |manifest| manifest.name.to_s == manifest_name }
    end
  end
end
