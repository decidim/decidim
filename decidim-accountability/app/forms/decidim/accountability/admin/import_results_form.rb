# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ImportResultsForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::ProcessesFileLocally

        attribute :file, Decidim::Attributes::Blob

        validates :file, presence: true, file_content_type: { allow: ["text/csv"] }

        def local_file_path
          process_file_locally(file) do |file_path|
            file_path
          end
        end
      end
    end
  end
end
