# frozen_string_literal: true

module Decidim
  module Admin
    class ImportForm < Form
      ACCEPTED_MIME_TYPES = Decidim::Admin::Import::Readers::ACCEPTED_MIME_TYPES
      include Decidim::HasUploadValidations
      include Decidim::ProcessesFileLocally

      attribute :name, String
      attribute :file, Decidim::Attributes::Blob

      validates :file, presence: true
      validates :name, presence: true
      validate :check_accepted_mime_type
      validate :check_invalid_file, if: -> { file.present? && accepted_mime_type? }
      validate :verify_import, if: -> { file.present? && accepted_mime_type? && !importer.invalid_file? }

      def importer
        @importer ||= importer_for(file, mime_type)
      end

      private

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

      def verify_import
        return if importer.verify

        importer.errors.each do |error|
          errors.add(:file, error.message)
        end
      end

      def mime_type
        file&.content_type
      end

      def creator_class
        manifest.creator
      end

      def importer_for(path, mime_type)
        Import::ImporterFactory.build(
          path,
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
