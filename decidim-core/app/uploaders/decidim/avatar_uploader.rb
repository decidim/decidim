# frozen_string_literal: true

module Decidim
  # This class deals with uploading avatars to a User.
  class AvatarUploader < ApplicationUploader
    include CarrierWave::MiniMagick

    process :validate_dimensions

    protected

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_whitelist
      [
        %r{image\/}
      ]
    end

    # A simple check to avoid DoS with maliciously crafted images, or just to
    # avoid reckless users that upload gigapixels images.
    #
    # See https://hackerone.com/reports/390
    def validate_dimensions
      manipulate! do |image|
        raise CarrierWave::IntegrityError, I18n.t("carrierwave.errors.image_too_big") if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }
        image
      end
    end

    def max_image_height_or_width
      8000
    end

    def default_url(*)
      ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end
  end
end
