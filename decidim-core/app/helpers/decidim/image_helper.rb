# frozen_string_literal: true

module Decidim
  module ImageHelper
    def decidim_picture_tag(model, mounted_as, variant: nil, **options)
      return unless model.respond_to?(:attached_uploader)

      uploader = model.attached_uploader(mounted_as)
      return unless uploader&.attached?

      avif_url = uploader.avif_url(variant)
      original_url = uploader.url(variant:)

      picture_tag([avif_url, original_url].compact_blank, options)
    end
  end
end
