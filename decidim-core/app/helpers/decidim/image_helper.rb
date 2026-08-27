# frozen_string_literal: true

module Decidim
  module ImageHelper
    def decidim_picture_tag(model, mounted_as, variant: nil, **options)
      return if model.send(mounted_as).blank?
      return unless model.respond_to?(:attached_uploader)

      uploader = model.attached_uploader(mounted_as)

      pictures = [
        uploader.avif_url(variant),
        uploader.url(variant:)
      ].compact_blank

      return if pictures.empty?

      picture_tag(pictures, options)
    end
  end
end
