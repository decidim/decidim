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
      blob_from_attachment_image || blob_from_description || blob_from_participatory_space || blob_from_content_blocks
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
    def blob_from_description
      html = @resource.try(:body) || @resource.try(:description) || @resource.try(:short_description)
      return unless html

      html = translated_attribute(html).strip if html.is_a?(Hash)
      return if html.blank?

      image_url = Nokogiri::HTML(html).css("img").first&.[]("src")
      return if image_url.blank?

      blob_key = image_url.split("/").second_to_last
      ActiveStorage::Blob.find_signed(blob_key) if blob_key.present?
    end

    # Fetches the image blob from the participatory space.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_participatory_space
      participatory_space = @resource&.participatory_space
      return unless participatory_space

      participatory_space.hero_image&.blob || participatory_space.banner_image&.blob
    end

    # Resizes the image blob to the specified dimensions (1200x630) if it's larger.
    #
    # @param [ActiveStorage::Blob] blob - The image blob to be resized.
    #
    # @return [String] - The URL of the resized image.
    def resize_image_blob(blob)
      return unless blob

      resized_variant = blob.variant(resize_to_limit: [1200, 630]).processed
      Rails.application.routes.url_helpers.rails_representation_url(resized_variant, only_path: true)
    end
  end
end
