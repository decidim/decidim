# frozen_string_literal: true

module Decidim
  module Verifications
    # This class deals with uploading identity documents.
    class AttachmentUploader < ImageUploader
      version :thumbnail do
        process resize_to_limit: [90, nil]
      end

      version :big do
        process resize_to_limit: [600, nil]
      end
    end
  end
end
