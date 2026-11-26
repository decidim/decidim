# frozen_string_literal: true

module Decidim
  # Resolves the most appropriate image URL for meta tags from a given resource within an organization.
  # Searches in the following order: attachment images, images in resource description, participatory space images, and default content block images.
  # Description images are only used when they belong to an editor image in the current organization.
  # Ensures the selected image is resized to 1200x630 pixels.
  class MetaImageUrlResolver
    include TranslatableAttributes

    IMAGE_FIELDS = [:hero_image, :banner_image, :avatar].freeze
    DESCRIPTION_FIELDS = [:body, :description, :short_description, :content, :additional_info].freeze
    MAX_DESCRIPTION_IMAGES = 20
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
      return unless blob.variable?
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
    # Only a limited number of distinct image sources are inspected so that
    # descriptions with many rejected image tags cannot trigger repeated blob
    # lookups.
    #
    # @return [ActiveStorage::Blob, nil] - The image blob or nil if not found.
    def blob_from_description
      inspected_urls = Set.new

      DESCRIPTION_FIELDS.each do |field|
        html = description_field_html(field)
        next if html.blank?

        blob = blob_from_description_html(html, inspected_urls)
        return blob if blob.present?
        return nil if inspected_urls.size >= MAX_DESCRIPTION_IMAGES
      end

      nil
    end

    def description_field_html(field)
      html = resource.try(field)
      return if html.blank?

      return translated_attribute(html).strip if html.is_a?(Hash)

      html
    end

    def blob_from_description_html(html, inspected_urls)
      Nokogiri::HTML(html).css("img").each do |image_element|
        image_url = image_element["src"]
        next if image_url.blank?
        next if inspected_urls.include?(image_url)
        break if inspected_urls.size >= MAX_DESCRIPTION_IMAGES

        inspected_urls << image_url

        blob = find_blob_from_url(image_url)
        return blob if blob.present? && allowed_blob?(blob)
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

    def find_blob_from_url(url)
      if url.start_with?("gid://")
        gid = url[%r{\Agid://[^/]+/[^/]+/\d+}]
        return find_blob_from_global_id(gid) if gid
      end

      find_blob_by_key(url.split("/").second_to_last)
    end

    # A blob that no longer exists is treated as "no blob for this candidate"
    # so the remaining image candidates are still considered. Other backend
    # errors keep propagating.
    #
    # Rescuing ActiveRecord::RecordNotFound (instead of using
    # GlobalID::Locator.fetch) keeps this compatible with globalid versions
    # older than 1.4.0, where that method is not available.
    def find_blob_from_global_id(gid)
      GlobalID::Locator.locate(gid, only: ActiveStorage::Blob)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_blob_by_key(blob_key)
      ActiveStorage::Blob.find_signed(blob_key) if blob_key.present?
    end

    # Only blobs attached to editor images in the current organization are
    # allowed. This prevents user-controlled content from resolving private
    # blobs (for example verification attachments) or blobs from other
    # organizations.
    def allowed_blob?(blob)
      return false if organization.blank?

      blob.attachments.any? do |attachment|
        attachment.record_type == "Decidim::EditorImage" &&
          Decidim::EditorImage.exists?(id: attachment.record_id, organization:)
      end
    end

    def blob_from_attached_file(file)
      return unless file.respond_to?(:attached?) && file.attached?

      file.blob
    end
  end
end
