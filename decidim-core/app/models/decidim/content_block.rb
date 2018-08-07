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

    delegate :public_name_key, :has_settings?, :settings_form_cell, :cell, to: :manifest

    # Public: finds the published content blocks for the given scope and
    # organization. Returns them ordered by ascending weight (lowest first).
    def self.for_scope(scope, organization:)
      where(organization: organization, scope: scope)
        .order(weight: :asc)
    end

    def manifest
      @manifest ||= Decidim.content_blocks.for(scope).find { |manifest| manifest.name.to_s == manifest_name }
    end

    def settings
      manifest.settings.schema.new(self[:settings])
    end

    def images
      @images ||= ImageRegistry.new(self)
    end

    # Internal class to easily access the attachments that hold the images for
    # the current content block.
    #
    # If the manifest for the current content block defines a
    # `:background_image`, then this class allows you to do this:
    #
    #     content_block.images.background_image
    class ImageRegistry
      include Virtus.model
      include ActiveModel::Validations

      def initialize(block)
        @block = block
        @images = {}
        define_methods
      end

      attr_reader :block

      def define_methods
        block.manifest.image_names.each do |image_name|
          self.class.define_method image_name do
            @images[image_name] ||= Attachment.find_by(attached_to: @block, title: { name: image_name })
          end
        end
      end
    end
  end
end
