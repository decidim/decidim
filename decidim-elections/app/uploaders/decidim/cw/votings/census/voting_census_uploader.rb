# frozen_string_literal: true

module Decidim::Cw
  module Votings
    module Census
      # This class deals with saving voting cenusus access codes export Zip Files to App
      class VotingCensusUploader < Decidim::Cw::ApplicationUploader
        # Override the directory where uploaded files will be stored.
        def store_dir
          default_path = "uploads/voting-census/"

          return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

          default_path
        end
      end
    end
  end
end
