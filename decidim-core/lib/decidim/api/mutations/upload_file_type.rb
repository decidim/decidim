# frozen_string_literal: true

module Decidim
  module Core
    class UploadFileType < Decidim::Api::Types::BaseMutation
      include Decidim::Api::GraphqlPermissions

      description "Upload a file via multipart form"

      argument :file, Decidim::Api::Types::BaseUpload, required: true

      field :blob, Decidim::Core::BlobType, null: true

      def resolve(file:)
        errors = validate_file(file)
        return GraphQL::ExecutionError.new(errors.join(", ")) unless errors.empty?

        filename = File.basename(file.original_filename)
        content_type = file.content_type || Marcel::MimeType.for(file.tempfile, filename: filename)

        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: filename,
          content_type: content_type
        )

        { blob: blob }
      end

      def authorized?(file:)
        super && allowed_to?(:create, :blob, nil, context, scope: :admin)
      end

      private

      def validate_file(file)
        errors = []
        return [I18n.t("decidim.api.file_upload.errors.file_no_exists")] unless file.present? 

        filename = file.original_filename
        ext = File.extname(filename).delete_prefix(".").downcase
        allowed_exts = Decidim.organization_settings(context[:current_organization]).upload_allowed_file_extensions_admin || []
        errors << I18n.t("decidim.api.file_upload.errors.file_ext_not_supported") unless allowed_exts.include?(ext)

        content_type = file.content_type || Marcel::MimeType.for(file.tempfile, filename: filename)
        allowed_types = Decidim.organization_settings(context[:current_organization]).upload_allowed_content_types_admin || []
        unless allowed_types.any? { |t| (t.is_a?(Regexp) ? t.match?(content_type) : t.to_s == content_type) }
          errors << I18n.t("decidim.api.file_upload.errors.type_not_supported")
        end

        max_bytes = Decidim.organization_settings(context[:current_organization]).upload.maximum_file_size.default.megabytes
        if file.size > max_bytes
          errors << I18n.t("decidim.api.file_upload.errors.file_too_large")
        end

        errors
      end
    end
  end
end
