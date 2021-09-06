# frozen_string_literal: true

module Decidim
  module Admin
    class ImportForm < Form
      ACCEPTED_MIME_TYPES = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES
      include Decidim::HasUploadValidations

      attribute :name, String
      attribute :file

      validates :file, presence: true
      validates :name, presence: true
      validate :check_accepted_mime_type
      validate :check_invalid_file, if: -> { file.present? && accepted_mime_type? }

      with_options if: -> { file.present? && accepted_mime_type? && !importer.invalid_file? } do
        validate :check_duplicate_columns
        validate :check_missing_columns
        validate :check_invalid_lines
      end

      def check_accepted_mime_type
        return if accepted_mime_type?

        errors.add(
          :file,
          I18n.t(
            "activemodel.errors.new_import.attributes.file.invalid_mime_type",
            valid_mime_types: ACCEPTED_MIME_TYPES.keys.map do |m|
              I18n.t("decidim.admin.new_import.accepted_mime_types.#{m}")
            end.join(", ")
          )
        )
      end

      def check_invalid_file
        return unless importer.invalid_file?

        errors.add(:file, I18n.t("activemodel.errors.new_import.attributes.file.invalid_file"))
      end

      def check_duplicate_columns
        message = importer.duplicate_columns_message
        errors.add(:file, message) if message
      end

      def check_missing_columns
        message = importer.missing_columns_message
        errors.add(:file, message) if message
      end

      def check_invalid_lines
        message = importer.invalid_indexes_message
        errors.add(:file, message) if message
      end

      def file_path
        file&.path
      end

      def mime_type
        file&.content_type
      end

      def creator_class
        manifest.creator
      end

      def importer
        @importer ||= importer_for(file_path, mime_type)
      end

      def importer_for(filepath, mime_type)
        Import::ImporterFactory.build(
          filepath,
          mime_type,
          context: importer_context,
          creator: creator_class
        )
      end

      protected

      def accepted_mime_type?
        return true if ACCEPTED_MIME_TYPES.values.include?(mime_type)

        false
      end

      def importer_context
        context
      end

      def manifest
        @manifest ||= current_component.manifest.import_manifests.find do |import_manifest|
          import_manifest.name.to_s == name
        end
      end
    end
  end
end
