# frozen_string_literal: true

module Decidim
  module Initiatives
    # Signature handler which reproduces the old feature of
    # `collect_personal_data` of initiative types. The handler will collect the
    # name and surname, the document number and the date of birth
    class LegacySignatureHandler < SignatureHandler
      attribute :name_and_surname, String
      attribute :document_number, String
      attribute :date_of_birth, Date
      attribute :postal_code, String

      validates :name_and_surname, :document_number, :date_of_birth, :postal_code, presence: true

      def unique_id
        document_number
      end

      def metadata
        super.merge(name_and_surname:, document_number:, date_of_birth:, postal_code:)
      end
    end
  end
end
