# frozen_string_literal: true

module Decidim
  # This class deals with uploading record specific images that have more
  # limited content types than the defaults.
  class RecordImageUploader < ImageUploader
    def content_type_whitelist
      %w(image/jpeg image/png)
    end

    def extension_whitelist
      %w(jpeg jpg png)
    end
  end
end
