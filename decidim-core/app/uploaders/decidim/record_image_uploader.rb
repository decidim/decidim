# frozen_string_literal: true

module Decidim
  # This class deals with uploading record specific images that have more
  # limited content types than the defaults.
  class RecordImageUploader < ImageUploader
    def content_type_allowlist
      %w(image/jpeg image/png)
    end

    def extension_allowlist
      %w(jpeg jpg png)
    end
  end
end
