# frozen_string_literal: true
module Decidim
  # This class deals with uploading official images to Proposals.
  class OfficialImageProposalUploader < ImageUploader
    process resize_to_limit: [1000, 1000]
  end
end
