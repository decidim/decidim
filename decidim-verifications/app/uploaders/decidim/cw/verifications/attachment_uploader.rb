# frozen_string_literal: true

module Decidim::Cw
  module Verifications
    # This class deals with uploading identity documents.
    class AttachmentUploader < Decidim::Cw::ImageUploader
      set_variants do
        {
          thumbnail: { resize_to_limit: [90, nil] },
          big: { resize_to_limit: [600, nil] }
        }
      end
    end
  end
end
