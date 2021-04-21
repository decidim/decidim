# frozen_string_literal: true

module Decidim
  # This class deals with uploading attachments to a participatory space.
  class AttachmentUploader < ApplicationUploader
    def validable_dimensions
      true
    end

    set_variants do
      {
        thumbnail: { resize_to_fit: [nil, 237] },
        big: { resize_to_limit: [nil, 1000] }
      }
    end

    def extension_allowlist
      case upload_context
      when :admin
        Decidim.organization_settings(model).upload_allowed_file_extensions_admin
      else
        Decidim.organization_settings(model).upload_allowed_file_extensions
      end
    end

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_allowlist
      case upload_context
      when :admin
        Decidim.organization_settings(model).upload_allowed_content_types_admin
      else
        Decidim.organization_settings(model).upload_allowed_content_types
      end
    end

    def max_image_height_or_width
      8000
    end

    protected

    # Strips out all embedded information from the image
    def upload_context
      return :participant unless model.respond_to?(:context)

      model.context
    end
  end
end
