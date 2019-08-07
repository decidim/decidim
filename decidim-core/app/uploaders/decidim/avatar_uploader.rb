# frozen_string_literal: true

module Decidim
  # This class deals with uploading avatars to a User.
  class AvatarUploader < ImageUploader
    include CarrierWave::MiniMagick

    process :validate_dimensions

    version :profile do
      process resize_to_fill: [536, 640] # double the size, for retina displays
    end

    version :big, from_version: :profile do
      process resize_to_fit: [80, 80]
    end

    version :thumb, from_version: :big do
      process resize_to_fit: [40, 40]
    end

    def default_url(*)
      ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end
  end
end
