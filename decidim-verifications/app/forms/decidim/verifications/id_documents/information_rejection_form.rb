# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # A form object to be used for reject a verification request by identity
      # document upload.
      class InformationRejectionForm < InformationForm
        def verification_metadata
          super.merge("rejected" => true)
        end
      end
    end
  end
end
