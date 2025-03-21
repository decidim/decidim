# frozen_string_literal: true

module Decidim
  # Resolves the most appropriate image URL for meta tags from a given resource within an organization.
  # Searches in the following order: attachment images, images in resource description, participatory space images, and default content block images.
  # Ensures the selected image is resized to 1200x630 pixels.
  class MetaImageUrlResolver
    include TranslatableAttributes

    IMAGE_FIELDS = [:hero_image, :banner_image, :avatar].freeze
    DESCRIPTION_FIELDS = [:body, :description, :short_description, :content, :additional_info].freeze
    CONTENT_BLOCK_TYPES = {
      { manifest_name: :hero, scope_name: :homepage } => [:background_image]
    }.freeze

    def initialize(resource, organization)
      @resource = resource
      @organization = organization
    end

    attr_reader :resource, :organization

    # Resolves the image blob to be used for meta tags.
    #
    # @return [String, nil] - The resolved image blob or nil if no image is found.
    def resolve
      return unless blob
      return unless blob.service.exist?(blob.key)

      resized_variant = blob.variant(resize_to_limit: [1200, 630]).processed
      Rails.application.routes.url_helpers.rails_representation_url(resized_variant, only_path: true)
    end

    # Determines the image blob to be used for meta tags by following a hierarchy.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if no image is found.
    def blob
      @blob ||= blob_from_image_fields || blob_from_attachments || blob_from_description || blob_from_participatory_space || blob_from_content_blocks
    end

    private

    # Fetches the image blob from the resource's attached image fields.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_image_fields
      IMAGE_FIELDS.each do |image_name|
        next unless resource.respond_to?(image_name) && resource.respond_to?(:attached_uploader)

        blob = blob_from_attached_file(resource.send(image_name))
        return blob if blob.present?
      end

      nil
    end

    # Fetches the first attachment image blob.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_attachments
      attachment = resource.try(:attachments)&.find { |a| a.content_type.in?(%w(image/jpeg image/png image/webp)) }
      blob_from_attached_file(attachment&.file)
    end

    # Extracts the first image blob from the resource description.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_description
      DESCRIPTION_FIELDS.each do |field|
        html = resource.try(field)
        next unless html

        html = translated_attribute(html).strip if html.is_a?(Hash)
        next if html.blank?

        image_element = Nokogiri::HTML(html).css("img").first
        next unless image_element

        image_url = image_element["src"]
        next if image_url.blank?

        blob = find_blob_by_key(image_url.split("/").second_to_last)
        return blob if blob.present?
      end

      nil
    end

    # Fetches the image blob from the participatory space.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_participatory_space
      participatory_space = resource.try(:participatory_space)
      return unless participatory_space

      MetaImageUrlResolver.new(participatory_space, organization).blob
    end

    # Fetches the default homepage image blob.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_content_blocks
      CONTENT_BLOCK_TYPES.each do |type, image_names|
        Decidim::ContentBlock.where(type.merge(organization:)).find_each do |content_block|
          next unless content_block.respond_to?(:images_container)

          image_names.each do |image_name|
            next unless content_block.images_container.respond_to?(image_name)

            blob = blob_from_attached_file(content_block.images_container.send(image_name))
            return blob if blob.present?
          end
        end
      end

      nil
    end

    def find_blob_by_key(blob_key)
      ActiveStorage::Blob.find_signed(blob_key) if blob_key.present?
    end

    def blob_from_attached_file(file)
      return unless file.respond_to?(:attached?) && file.attached?

      file.blob
    end
  end
end
