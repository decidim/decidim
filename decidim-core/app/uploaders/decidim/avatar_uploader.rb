# frozen_string_literal: true

module Decidim
  # This class deals with uploading avatars to a User.
  class AvatarUploader < ImageUploader
    include CarrierWave::MiniMagick

    process :validate_dimensions

    version :big do
      process resize_and_pad: [500, 500]
    end

    version :thumb do
      process resize_and_pad: [100, 100]
    end

    def default_url(*)
      ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end
  end
end
