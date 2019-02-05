# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from a participatory text.
      class ImportParticipatoryTextForm < Decidim::Form
        include TranslatableAttributes

        ACCEPTED_MIME_TYPES = Decidim::Proposals::DocToMarkdown::ACCEPTED_MIME_TYPES

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :document

        validates :title, translatable_presence: true
        validate :accepted_mime_type

        def default_locale
          current_participatory_space.organization.default_locale
        end

        def document_text
          @document_text ||= document&.read
        end

        def document_type
          document.content_type
        end

        def accepted_mime_type
          return if ACCEPTED_MIME_TYPES.has_value?(document_type)

          errors.add(:document,
                     I18n.t("activemodel.errors.models.participatory_text.attributes.document.invalid_document_type",
                            valid_mime_types: ACCEPTED_MIME_TYPES.keys.map do |m|
                              I18n.t("decidim.proposals.admin.participatory_texts.new_import.accepted_mime_types.#{m}")
                            end.join(", ")))
        end
      end
    end
  end
end
