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
        attribute :verification_type, String

        validates :document_type,
                  inclusion: { in: DOCUMENT_TYPES },
                  presence: true

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validates :verification_type,
                  presence: true,
                  inclusion: { in: %w(offline online) }

        def handler_name
          "id_documents"
        end

        def map_model(model)
          self.document_type = model.verification_metadata["document_type"]
          self.document_number = model.verification_metadata["document_number"]
          self.verification_type = model.verification_metadata["verification_type"].presence || "online"
        end

        def verification_metadata
          {
            "document_type" => document_type,
            "document_number" => document_number,
            "verification_type" => verification_type
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

        def uses_online_method?
          verification_type == "online"
        end
      end
    end
  end
end
