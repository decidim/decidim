# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading avatars to a User.
  class AvatarUploader < ImageUploader
    set_variants do
      {
        profile: { resize_to_fill: [536, 640] },
        big: { resize_to_fit: [80, 80] },
        thumb: { resize_to_fit: [40, 40] }
      }
    end

    process :validate_dimensions

    def default_url(*)
      ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end

    def default_multiuser_url(*)
      ActionController::Base.helpers.asset_path("decidim/avatar-multiuser.png")
    end
  end
end
