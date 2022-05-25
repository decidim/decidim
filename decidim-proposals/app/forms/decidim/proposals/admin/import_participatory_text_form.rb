# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from a participatory text.
      class ImportParticipatoryTextForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        # WARNING: consider adding/removing the relative translation key at
        # decidim.assemblies.admin.new_import.accepted_types when modifying this hash
        ACCEPTED_MIME_TYPES = Decidim::Proposals::DocToMarkdown::ACCEPTED_MIME_TYPES

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :document, Decidim::Attributes::Blob

        validates :title, translatable_presence: true
        validates :document, presence: true, if: :new_participatory_text?
        validate :document_type_must_be_valid, if: :document

        # Assume it's a NEW participatory_text if there are no proposals
        # Validate document presence while CREATING proposals from document
        # Allow skipping document validation while UPDATING title/description
        def new_participatory_text?
          Decidim::Proposals::Proposal.where(component: current_component).blank?
        end

        def document_type_must_be_valid
          return if valid_mime_types.include?(document_type)

          errors.add(:document, i18n_invalid_document_type_text)
        end

        # Return ACCEPTED_MIME_TYPES plus `text/plain` for better markdown support
        def valid_mime_types
          ACCEPTED_MIME_TYPES.values + [Decidim::Proposals::DocToMarkdown::TEXT_PLAIN_MIME_TYPE] + ["application/octet-stream"]
        end

        def document_type
          document.content_type
        end

        def i18n_invalid_document_type_text
          I18n.t("allowed_file_content_types",
                 scope: "activemodel.errors.models.participatory_text.attributes.document",
                 types: i18n_valid_mime_types_text)
        end

        def i18n_valid_mime_types_text
          ACCEPTED_MIME_TYPES.keys.map do |mime_type|
            I18n.t(mime_type, scope: "decidim.proposals.admin.participatory_texts.new_import.accepted_mime_types")
          end.join(", ")
        end

        def default_locale
          current_participatory_space.organization.default_locale
        end

        def document_text
          @document_text ||= document&.download
        end
      end
    end
  end
end
