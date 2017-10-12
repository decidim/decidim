# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # A form object to be used as the base for identity document verification
      class InformationForm < AuthorizationHandler
        mimic :id_document_information

        DOCUMENT_TYPES = %w(DNI NIE passport).freeze

        attribute :document_number, String
        attribute :document_type, String

        validates :document_type,
                  inclusion: { in: DOCUMENT_TYPES },
                  presence: true

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        def handler_name
          "id_documents"
        end

        def verification_metadata
          {
            "document_type" => document_type,
            "document_number" => document_number
          }
        end

        def document_types_for_select
          DOCUMENT_TYPES.map do |type|
            [
              I18n.t(type.downcase, scope: "decidim.verifications.id_documents"),
              type
            ]
          end
        end
      end
    end
  end
end
