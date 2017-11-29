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
                  file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                  file_content_type: { allow: ["image/jpeg", "image/png"] },
                  presence: true
      end
    end
  end
end
