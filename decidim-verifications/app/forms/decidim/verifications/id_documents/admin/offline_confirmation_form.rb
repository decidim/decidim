# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # A form object to be used as the base for identity document verification
      module Admin
        class OfflineConfirmationForm < InformationForm
          attribute :email, String

          validates :email, presence: true
        end
      end
    end
  end
end
