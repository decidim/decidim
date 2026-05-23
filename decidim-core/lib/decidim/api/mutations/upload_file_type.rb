# frozen_string_literal: true

module Decidim
  module Core
    class UploadFileType < Decidim::Api::Types::BaseMutation
      include Decidim::Api::GraphqlPermissions

      required_scopes "admin:read", "admin:write"
      description "Upload a file via multipart form"

      argument :file, Decidim::Api::Types::BaseUpload, description: "File being uploaded", required: true

      field :blob, Decidim::Core::BlobType, description: "Blob of the uploaded file", null: true

      def resolve(file:)
        errors = validate_file(file)
        return GraphQL::ExecutionError.new(errors.join(", ")) unless errors.empty?

        filename = File.basename(file.original_filename)
        content_type = file.content_type || Marcel::MimeType.for(file.tempfile, filename:)

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

      # rubocop:disable Metrics/CyclomaticComplexity
      def validate_file(file)
        errors = []
        return [I18n.t("decidim.api.file_upload.errors.file_no_exists")] if file.blank?

        filename = file.original_filename
        ext = File.extname(filename).delete_prefix(".").downcase
        allowed_exts = Decidim.organization_settings(context[:current_organization]).upload_allowed_file_extensions_admin || []
        errors << I18n.t("decidim.api.file_upload.errors.file_ext_not_supported") unless allowed_exts.include?(ext)

        content_type = file.content_type || Marcel::MimeType.for(file.tempfile, filename:)
        allowed_types = Decidim.organization_settings(context[:current_organization]).upload_allowed_content_types_admin || []
        errors << I18n.t("decidim.api.file_upload.errors.type_not_supported") unless allowed_types.any? { |t| (t.is_a?(Regexp) ? t.match?(content_type) : t.to_s == content_type) }

        max_bytes = Decidim.organization_settings(context[:current_organization]).upload.maximum_file_size.default.megabytes
        errors << I18n.t("decidim.api.file_upload.errors.file_too_large") if file.size > max_bytes

        errors
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
