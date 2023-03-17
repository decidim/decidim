# frozen_string_literal: true

module Decidim
  # This class deals with uploading avatars to a User.
  class AvatarUploader < ImageUploader
    set_variants do
      {
        profile: { resize_to_fill: [536, 640] },
        big: { resize_to_fit: [80, 80] },
        thumb: { resize_to_fit: [40, 40] }
      }
    end

    def default_url(*)
      AssetRouter::Pipeline.new("media/images/default-avatar.svg", model:).url
    end

    def default_multiuser_url(*)
      AssetRouter::Pipeline.new("media/images/avatar-multiuser.png", model:).url
    end
  end
end
