# frozen_string_literal: true

module Decidim
  # This class deals with uploading images to newsletters.
  class NewsletterTemplateImageUploader < ImageUploader
    process resize_to_fit: [550, 300]

    def max_image_height_or_width
      8000
    end

    # Overwrite: If the content block is in preview mode, then we show the
    # preview image. Otherwise, we use the default behavior.
    def url(*args)
      return preview_url if in_preview?

      super
    end

    def preview_url(*_args)
      manifest_images = model.content_block.manifest.images
      image = manifest_images.find { |manifest_image| manifest_image[:name] == mounted_as } || {}
      preview = image[:preview]

      if preview && preview.respond_to?(:call)
        preview.call
      else
        preview
      end
    end

    def in_preview?
      model.content_block.in_preview
    end
  end
end
