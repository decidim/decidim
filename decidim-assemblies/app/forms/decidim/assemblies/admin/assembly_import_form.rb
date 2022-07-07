# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to import an assembly from the admin
      # dashboard.
      #
      class AssemblyImportForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        JSON_MIME_TYPE = "application/json"
        # Accepted mime types
        # keys: are used for dynamic help text on admin form.
        # values: are used to validate the file format of imported document.
        #
        # WARNING: consider adding/removing the relative translation key at
        # decidim.assemblies.admin.new_import.accepted_types when modifying this hash
        ACCEPTED_TYPES = {
          json: JSON_MIME_TYPE
        }.freeze

        translatable_attribute :title, String

        mimic :assembly

        attribute :slug, String
        attribute :import_steps, Boolean, default: false
        attribute :import_categories, Boolean, default: true
        attribute :import_attachments, Boolean, default: true
        attribute :import_components, Boolean, default: true
        attribute :document, Decidim::Attributes::Blob

        validates :document, file_content_type: { allow: ACCEPTED_TYPES.values }
        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }
        validates :title, translatable_presence: true
        validate :slug_uniqueness

        validate :document_type_must_be_valid, if: :document

        def document_text
          @document_text ||= document&.download
        end

        def document_type_must_be_valid
          return if valid_mime_types.include?(document_type)

          errors.add(:document, i18n_invalid_document_type_text)
        end

        # Return ACCEPTED_MIME_TYPES plus `text/plain` for better markdown support
        def valid_mime_types
          ACCEPTED_TYPES.values
        end

        def document_type
          document.content_type
        end

        def i18n_invalid_document_type_text
          I18n.t("allowed_file_content_types",
                 scope: "activemodel.errors.models.assembly.attributes.document",
                 types: i18n_valid_mime_types_text)
        end

        def i18n_valid_mime_types_text
          ACCEPTED_TYPES.keys.map do |mime_type|
            I18n.t(mime_type, scope: "decidim.assemblies.admin.new_import.accepted_types")
          end.join(", ")
        end

        private

        def slug_uniqueness
          return unless OrganizationAssemblies.new(current_organization).query.where(slug: slug).where.not(id: id).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
