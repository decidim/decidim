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

    def resolve
      determine_image_url.presence || @image_url
    end

    private

    # Determines the image URL to be used for meta tags.
    #
    # @return [String] - A String of the absolute URL of the image.
    def determine_image_url
      return add_base_url_to(@image_url) if @image_url.present?
      return unless @resource

      url = fetch_attachment_image_url || fetch_image_from_description || fetch_participatory_space_image_url
      add_base_url_to(url) if url.present?
    end

    # Fetches the URL of the first attachment image.
    #
    # @return [String] - A String of the absolute URL of the attachment image.
    def fetch_attachment_image_url
      attachment = find_image_attachment(@resource) || find_image_attachment(@resource.try(:participatory_space))
      return unless attachment

      if attachment.file&.attached?
        Rails.application.routes.url_helpers.rails_representation_url(
          attachment.file.variant(resize_to_limit: [1200, 630]).processed,
          only_path: true
        )
      end
    end

    def find_image_attachment(entity)
      entity.try(:attachments)&.find_by(content_type: %w(image/jpeg image/png))
    end

    # Extracts the first image URL from the resource description.
    #
    # @return [String] - A String of the relative URL of the first image found in the body.
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
    # @return [String] - A String of the absolute URL of the participatory space image.
    def fetch_participatory_space_image_url
      image_path = @resource.participatory_space&.attached_uploader(:hero_image)&.path
      resize_image_url(image_path) if image_path.present?
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
