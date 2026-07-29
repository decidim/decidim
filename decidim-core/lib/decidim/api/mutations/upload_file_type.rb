# frozen_string_literal: true

module Decidim
  module Core
    class UploadFileType < Decidim::Api::Types::BaseMutation
      include Decidim::Api::GraphqlPermissions

      description "Upload a file via multipart form"

      argument :file, Decidim::Api::Types::BaseUpload, description: "File being uploaded", required: true

      field :blob, Decidim::Core::BlobType, description: "Blob of the uploaded file", null: true

      def resolve(file:)
        validate_file!(file)

        filename = File.basename(file.original_filename)
        content_type = detect_content_type(file)

        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename:,
          content_type:
        )

        { blob: }
      end

      def authorized?(file:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:create, :blob, nil, context)

        true
      end

      private

      def validate_file!(file)
        validate_existence!(file)
        validate_extension!(file)
        validate_content_type!(file)
        validate_size!(file)
      end

      def validate_content_type!(file)
        content_type = detect_content_type(file)
        allowed_types = Decidim.organization_settings(current_organization).upload_allowed_content_types_admin || []

        return if allowed_types.any? { |t| (t.is_a?(Regexp) ? t.match?(content_type) : t.to_s == content_type) }

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.type_not_supported")
      end

      def validate_size!(file)
        max_bytes = Decidim.organization_settings(current_organization).upload.maximum_file_size.default.megabytes

        return if file.size <= max_bytes

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_too_large")
      end

      def validate_existence!(file)
        return if file.present?

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_no_exists")
      end

      def validate_extension!(file)
        ext = File.extname(file.original_filename).delete_prefix(".").downcase
        allowed_exts = Decidim.organization_settings(current_organization).upload_allowed_file_extensions_admin || []

        return if allowed_exts.include?(ext)

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_ext_not_supported")
      end

      def detect_content_type(file)
        file.content_type || Marcel::MimeType.for(file.tempfile, name: File.basename(file.original_filename))
      end
    end
  end
end
