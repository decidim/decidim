# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # A form object to be used when public users want to get verified by
      # uploading their identity documents.
      class UploadForm < InformationForm
        mimic :id_document_upload

        attribute :verification_attachment, String

        validates :verification_attachment,
                  passthru: { to: Decidim::Authorization },
                  presence: true,
                  if: :uses_online_method?
      end
    end
  end
end
