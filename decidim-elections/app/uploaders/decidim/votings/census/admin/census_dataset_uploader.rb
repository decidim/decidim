# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # This class deals with saving imploaded census csv files
        class CensusDatasetUploader < ApplicationUploader
          def content_type_allowlist
            %w(text/csv)
          end

          def extension_allowlist
            %w(csv)
          end

          # Override the directory where uploaded files will be stored.
          def store_dir
            default_path = "uploads/census/"

            return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

            default_path
          end
        end
      end
    end
  end
end
