# frozen_string_literal: true

module Decidim
  class MetaImageUrlResolver
    include TranslatableAttributes

    delegate :add_base_url_to, :resolve_base_url, to: :@helper

    def initialize(image_url, resource, helper)
      @image_url = image_url
      @resource = resource
      @helper = helper
    end

    # Resolves the image URL to be used for meta tags.
    #
    # @return [String] - The resolved image URL or the provided image URL.
    def resolve
      determine_image_url.presence || @image_url
    end

    private

    # Determines the image URL to be used for meta tags by following a hierarchy.
    #
    # @return [String] - A String of the absolute URL of the image.
    def determine_image_url
      return add_base_url_to(@image_url) if @image_url.present?
      return unless @resource

      url = fetch_attachment_image_url || fetch_image_from_description || fetch_participatory_space_image_url || fetch_default_image_url
      add_base_url_to(url) if url.present?
    end

    # Fetches the default hero image URL if available.
    #
    # @return [String, nil] - The URL of the hero image or nil if not found.
    def fetch_default_image_url
      @resource.try(:attached_uploader, :hero_image).try(:path)
    end

    # Fetches the URL of the first attachment image.
    #
    # @return [String, nil] - The URL of the attachment image or nil if not found.
    def fetch_attachment_image_url
      attachment = find_image_attachment(@resource)
      return unless attachment

      if attachment.file&.attached?
        Rails.application.routes.url_helpers.rails_representation_url(
          attachment.file.variant(resize_to_limit: [1200, 630]).processed,
          only_path: true
        )
      end
    end

    # Finds the first image attachment for a given entity.
    #
    # @param [Object] entity - The entity to search for attachments.
    #
    # @return [Decidim::Attachment, nil] - The first image attachment or nil if not found.
    def find_image_attachment(entity)
      entity.try(:attachments)&.find_by(content_type: %w(image/jpeg image/png))
    end

    # Extracts the first image URL from the resource description.
    #
    # @return [String] - A String of the relative URL of the first image found in the body or description.
    def fetch_image_from_description
      html = @resource.try(:body) || @resource.try(:description) || @resource.try(:short_description)
      return unless html

      html = @helper.translated_attribute(html).strip if html.is_a?(Hash)
      return if html.blank?

      doc = Nokogiri::HTML(html)
      image_url = doc.css("img").map { |img| img["src"] }.first
      resize_image_url(image_url) if image_url.present?
    end

    # Fetches the URL of the participatory space image.
    #
    # @return [String, nil] - The URL of the participatory space image or nil if not found.
    def fetch_participatory_space_image_url
      participatory_space = @resource.try(:participatory_space)
      return unless participatory_space

      attachment = find_image_attachment(participatory_space)
      return unless attachment

      if attachment.file&.attached?
        Rails.application.routes.url_helpers.rails_representation_url(
          attachment.file.variant(resize_to_limit: [1200, 630]).processed,
          only_path: true
        )
      else
        participatory_space.try(:attached_uploader, :hero_image).try(:path)
      end
    end

    # Resizes the image URL to the specified dimensions (1200x630) if it's larger.
    #
    # @param [String] image_url - The URL of the image to be resized.
    #
    # @return [String] - The URL of the resized image.
    def resize_image_url(image_url)
      blob_key = image_url.split("/").second_to_last
      blob = ActiveStorage::Blob.find_signed(blob_key)

      if blob
        resized_variant = blob.variant(resize_to_limit: [1200, 630]).processed
        Rails.application.routes.url_helpers.rails_representation_url(resized_variant, only_path: true)
      else
        image_url
      end
    rescue StandardError => e
      Rails.logger.error("Error processing image: #{e.message}")
      image_url
    end

    # Checks if the image is already resized to the required dimensions.
    #
    # @param [String] image_url - The URL of the image to check.
    #
    # @return [Boolean] - True if the image is already resized, false otherwise.
    def image_already_resized?(image_url)
      blob = ActiveStorage::Blob.find_signed(image_url.split("/").last)
      metadata = blob.metadata
      metadata["width"] <= 1200 && metadata["height"] <= 630
    rescue StandardError
      false
    end
  end
end
