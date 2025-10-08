# frozen_string_literal: true

module Decidim
  module Core
    class UploadFileType < Decidim::Api::Types::BaseMutation
      include Decidim::Api::GraphqlPermissions

      description "Upload a file from a server path"

      argument :file_path, String, required: true

      field :blob, Decidim::Core::BlobType, null: true

      def resolve(file_path:)
        file_path = File.expand_path(file_path)
        errors = validate_file(file_path)
        
        return GraphQL::ExecutionError.new(errors.join(",")) unless errors.empty?

        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(file_path, "rb"),
          filename: file_name(file_path),
          content_type: Marcel::MimeType.for(Pathname.new(file_path))
        )

        { blob: blob }
      end

      def authorized?(file_path:)
        super && allowed_to?(:create, :blob, nil, context, scope: :admin)
      end

      private

      def validate_file(file_path)
        errors = []
        errors << I18n.t("decidim.api.file_upload.errors.file_no_exists") unless File.exist?(file_path)
        errors << I18n.t("decidim.api.file_upload.errors.file_ext_not_supported") unless extension_allowed?(file_path)
        errors << I18n.t("decidim.api.file_upload.errors.type_not_supported") unless content_type_allowed?(file_path)

        errors
      end

      def extension_allowed?(file_path)
        ext = File.extname(file_name(file_path)).delete_prefix(".").downcase
        allowed_exts = Decidim.organization_settings(context[:current_organization]).upload_allowed_file_extensions_admin || []
        allowed_exts.include?(ext)
      end

      def content_type_allowed?(file_path)
        content_type = Marcel::MimeType.for(Pathname.new(file_path))
        allowed_types = Decidim.organization_settings(context[:current_organization]).upload_allowed_content_types_admin || []
        allowed_types.any? { |t| (t.is_a?(Regexp) ? t.match?(content_type) : t.to_s == content_type) }
      end

      def file_name(file_path)
        @file_name ||= File.basename(file_path)
      end
    end
  end
end
