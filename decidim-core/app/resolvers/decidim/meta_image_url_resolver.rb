# frozen_string_literal: true

module Decidim
  # Resolves the most appropriate image URL for meta tags from a given resource within an organization.
  # Searches in the following order: attachment images, images in resource description, participatory space images, and default content block images.
  # Ensures the selected image is resized to 1200x630 pixels.
  class MetaImageUrlResolver
    include TranslatableAttributes

    def initialize(resource, current_organization)
      @resource = resource
      @current_organization = current_organization
    end

    # Resolves the image URL to be used for meta tags.
    #
    # @return [String, nil] - The resolved image URL or nil if no image is found.
    def resolve
      blob = determine_image_blob.presence
      resize_image_blob(blob) if blob.present?
    end

    private

    # Determines the image blob to be used for meta tags by following a hierarchy.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if no image is found.
    def determine_image_blob
      blob_from_image_fields || blob_from_description(@resource) ||
        blob_from_participatory_space || blob_from_attachment_image || blob_from_content_blocks
    end

    # Fetches the image blob from the resource's attached image fields.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_image_fields
      path = get_attached_uploader_path(@resource, [:hero_image, :banner_image])
      return unless path

      blob_key = extract_blob_key_from_path(path)
      find_blob_by_key(blob_key)
    end

    # Fetches the default homepage image blob.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_content_blocks
      content_block = Decidim::ContentBlock.find_by(
        organization: @current_organization,
        manifest_name: :hero,
        scope_name: :homepage
      )

      return unless content_block

      attachment = content_block.attachments.first
      return unless attachment&.file&.attached?

      attachment.file.blob
    end

    # Fetches the first attachment image blob.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_attachment_image
      attachment = find_image_attachment(@resource)
      return unless attachment&.file&.attached?

      attachment.file.blob
    end

    # Finds the first image attachment for a given entity.
    #
    # @param [Object] entity - The entity to search for attachments.
    #
    # @return [Decidim::Attachment, nil] - The first image attachment or nil if not found.
    def find_image_attachment(entity)
      entity.try(:attachments)&.find { |a| a.content_type.in?(%w(image/jpeg image/png)) }
    end

    # Extracts the first image blob from the resource description.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_description(resource)
      html_fields = [resource.try(:body), resource.try(:description), resource.try(:short_description)]

      html_fields.each do |html|
        next unless html

        html = translated_attribute(html).strip if html.is_a?(Hash)
        next if html.blank?

        image_element = Nokogiri::HTML(html).css("img").first
        next unless image_element

        image_url = image_element["src"]
        next if image_url.blank?

        blob_key = extract_blob_key_from_path(image_url)
        blob = find_blob_by_key(blob_key)
        return blob if blob.present?
      end

      nil
    end

    # Fetches the image blob from the participatory space.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_participatory_space
      participatory_space = @resource.try(:participatory_space)
      return unless participatory_space

      blob = participatory_space.try(:hero_image).try(:blob) || participatory_space.try(:banner_image).try(:blob)
      blob.presence || blob_from_description(participatory_space)
    end

    # Resizes the image blob to the specified dimensions (1200x630) if it is larger.
    #
    # @param [ActiveStorage::Blob] blob - The image blob to be resized.
    #
    # @return [String] - The URL of the resized image.
    def resize_image_blob(blob)
      return unless blob

      resized_variant = blob.variant(resize_to_limit: [1200, 630]).processed
      Rails.application.routes.url_helpers.rails_representation_url(resized_variant, only_path: true)
    end

    def get_attached_uploader_path(resource, image_types)
      image_types.each do |image_type|
        path = resource.attached_uploader(image_type)&.path
        return path if path
      end
      nil
    end

    def extract_blob_key_from_path(path)
      path.split("/").second_to_last
    end

    def find_blob_by_key(blob_key)
      ActiveStorage::Blob.find_signed(blob_key) if blob_key.present?
    end
  end
end
