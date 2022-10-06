# frozen_string_literal: true

module Decidim
  # this class represents a content block manifest instance in the DB. Check the
  # docs on `ContentBlockRegistry` and `ContentBlockManifest` for more info.
  class ContentBlock < ApplicationRecord
    include Publicable

    attr_accessor :in_preview

    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"
    has_many :attachments, foreign_key: "decidim_content_block_id", class_name: "Decidim::ContentBlockAttachment", inverse_of: :content_block, dependent: :destroy

    delegate :public_name_key, :has_settings?, :settings_form_cell, :cell, to: :manifest

    before_save :save_images
    after_save :reload_images

    validates_associated :images_container

    # Public: finds the published content blocks for the given scope and
    # organization. Returns them ordered by ascending weight (lowest first).
    def self.for_scope(scope, organization:)
      where(organization:, scope_name: scope)
        .order(weight: :asc)
    end

    def manifest
      @manifest ||= Decidim.content_blocks.for(scope_name).find { |manifest| manifest.name.to_s == manifest_name }
    end

    # Public: Uses the `SettingsManifest` class to generate a settings schema
    # and fill it with the content blocks current settings. This eases the
    # access to those settings values.
    #
    # Returns an object that responds to the settings defined in the content
    # block manifest.
    def settings
      manifest.settings.schema.new(self[:settings])
    end

    def reload(*)
      @manifest_attachments = nil
      @images_container = nil
      super
    end

    # Public: Holds access to the images related to the content block. This
    # method generates a dynamic class that encapsulates the uploaders for the
    # content block images, and eases the access to them. It's a little bit
    # hacky, but it's the only way I could come up with in order to let content
    # block images have different uploaders.
    #
    # Examples:
    #
    #     # This will process the image with the uploader defined at the
    #     # manifest, upload it and save the record.
    #     content_block.images_container.my_image = params[:my_image]
    #     content_block.save!
    #
    #     # This is how you can access the image data, just like with any other
    #     # uploader field. You can use the uploader variants too.
    #     content_block.images_container.attached_uploader(:my_image).path
    #     content_block.images_container.attached_uploader(:my_image).path(variant: :big)
    #
    #     # This will delete the attached image
    #     content_block.images_container.my_image = nil
    #     content_block.save!
    #
    # Returns an object that responds to the image names defined in the content
    # block manifest.
    def images_container
      return @images_container if @images_container

      attachments = manifest_attachments

      @images_container = Class.new do
        include ActiveModel::Validations
        include Decidim::HasUploadValidations

        cattr_accessor :manifest_attachments
        attr_reader :content_block

        def self.name
          to_s.camelize
        end

        delegate :id, :organization, to: :content_block

        def initialize(content_block)
          @content_block = content_block
        end

        attachments.each do |name, attachment|
          validates_upload name, uploader: attachment.uploader

          define_method(name) do
            attachment.file
          end

          define_method("#{name}=") do |file|
            attachment.file = file
          end
        end

        def attached_uploader(name)
          return if manifest_attachments[name].blank?

          manifest_attachments[name].attached_uploader(:file)
        end

        def save
          return unless content_block.persisted?

          manifest_attachments.values.map(&:save).all?
        end
      end

      @images_container.manifest_attachments = manifest_attachments
      @images_container = @images_container.new(self)
    end

    private

    def manifest_attachments
      @manifest_attachments ||= manifest.images.each_with_object({}) do |attachment_config, list|
        list[attachment_config[:name]] = attachments.find_or_initialize_by(name: attachment_config[:name])
      end
    end

    # Internal: Since we're using the `images_container` hack to hold the
    # uploaders, we need to manually trigger it to save the attached images.
    def save_images
      images_container.save
    end

    # On instance reloading we need to remove the `images_cointainer` cached
    # class so it gets regenerated with the new values.
    def reload_images
      @images_container = nil
    end
  end
end
