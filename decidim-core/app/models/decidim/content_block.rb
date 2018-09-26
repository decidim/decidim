# frozen_string_literal: true

module Decidim
  # this class represents a content block manifest instance in the DB. Check the
  # docs on `ContentBlockRegistry` and `ContentBlockManifest` for more info.
  class ContentBlock < ApplicationRecord
    include Publicable

    belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

    delegate :public_name_key, :has_settings?, :settings_form_cell, :cell, to: :manifest

    before_save :save_images
    after_save :reload_images

    # Public: finds the published content blocks for the given scope and
    # organization. Returns them ordered by ascending weight (lowest first).
    def self.for_scope(scope, organization:)
      where(organization: organization, scope: scope)
        .order(weight: :asc)
    end

    def manifest
      @manifest ||= Decidim.content_blocks.for(scope).find { |manifest| manifest.name.to_s == manifest_name }
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
    #     # uploader field. You can use the uploader versions too.
    #     content_block.images_container.my_image.url
    #     content_block.images_container.my_image.big.url
    #     content_block.save!
    #
    #     # This will delete the attached image
    #     content_block.images_container.my_image = nil
    #     content_block.save!
    #
    # Returns an object that responds to the image names defined in the content
    # block manifest.
    def images_container
      return @images_container if @images_container
      manifest = self.manifest

      @images_container = Class.new do
        extend ::CarrierWave::Mount
        include ActiveModel::Validations

        cattr_accessor :manifest, :manifest_scope
        attr_reader :content_block

        # Needed to calculate uploads URLs
        delegate :id, to: :content_block

        # Needed to customize the upload URL
        def self.name
          to_s.camelize
        end

        # Needed to customize the upload URL
        def self.to_s
          "decidim/#{manifest.name.to_s.underscore}_#{manifest_scope.to_s.underscore}_content_block"
        end

        def initialize(content_block)
          @content_block = content_block
        end

        def manifest
          self.class.manifest
        end

        manifest.images.each do |image_config|
          mount_uploader image_config[:name], image_config[:uploader].constantize
        end

        # This is used to access the upload file name from the container, given
        # an image name.
        def read_uploader(column)
          content_block.images[column.to_s]
        end

        # This is used to set the upload file name from the container, given
        # an image name.
        def write_uploader(column, value)
          content_block.images[column.to_s] = value
        end

        # When we save the content block, we force the container to save itself
        # too, so images can be processed, uploaded and stored in the DB.
        def save
          manifest.images.each do |image_config|
            send(:"write_#{image_config[:name]}_identifier")
            send(:"store_#{image_config[:name]}!")
          end
        end
      end

      @images_container.manifest = manifest
      @images_container.manifest_scope = scope
      @images_container = @images_container.new(self)
    end

    private

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
