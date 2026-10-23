# frozen_string_literal: true

module Decidim
  module Core
    # Validates an uploaded file and stores it as a blob.
    #
    # It is shared by the GraphQL entry points which receive a file from the
    # client: the upload mutation and the mutations which attach a file to a
    # record. The checks are applied before the blob is created so that an
    # invalid file is not stored; the model validations alone are not enough, as
    # they run when the blob is already in the storage and they use the content
    # type declared by the client instead of the one detected from the contents.
    module FileUpload
      def create_blob!(file)
        validate_file!(file)

        ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: sanitized_filename(file),
          content_type: detect_content_type(file)
        )
      end

      def validate_file!(file)
        validate_existence!(file)
        validate_extension!(file)
        validate_content_type!(file)
        validate_size!(file)
        validate_content!(file)
      end

      def validate_existence!(file)
        return if uploaded_file?(file)

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_no_exists")
      end

      def uploaded_file?(file)
        return false unless file

        # `Rack::Test::UploadedFile` is not a subclass of the multipart one, so it
        # has to be checked on its own.
        return true if defined?(Rack::Test::UploadedFile) && file.is_a?(Rack::Test::UploadedFile)

        file.is_a?(::Rack::Multipart::UploadedFile) || file.is_a?(ActionDispatch::Http::UploadedFile)
      end

      def validate_extension!(file)
        extension = File.extname(file.original_filename).delete_prefix(".").downcase
        allowed_extensions = Decidim.organization_settings(current_organization).upload_allowed_file_extensions_admin || []

        return if allowed_extensions.include?(extension)

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_ext_not_supported")
      end

      # Both the content type declared by the client and the one detected from the
      # file contents must be allowed. The declared type is not trusted, so a file
      # with an allowed extension and a false MIME declaration does not pass the
      # configured type restriction.
      def validate_content_type!(file)
        allowed_types = Decidim.organization_settings(current_organization).upload_allowed_content_types_admin || []

        [file.content_type, detect_content_type(file)].each do |content_type|
          next if allowed_content_type?(allowed_types, content_type)

          raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.type_not_supported")
        end
      end

      def allowed_content_type?(allowed_types, content_type)
        content_type = Decidim::UploadContentTypes.normalize(content_type)

        allowed_types.any? do |type|
          type.is_a?(Regexp) ? type.match?(content_type) : Decidim::UploadContentTypes.normalize(type) == content_type
        end
      end

      def validate_size!(file)
        max_bytes = Decidim.organization_settings(current_organization).upload.maximum_file_size.default.megabytes

        return if file.size <= max_bytes

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.file_too_large")
      end

      # SVG documents are XML-based and can contain active content which is executed
      # when the document is rendered by the browser, so the contents are validated
      # before the blob is stored. Only the documents which are well formed and do
      # not contain active content are accepted, as the malformed ones are rejected
      # by UploaderImageContentValidator when the blob is attached to a record, so
      # the upload does not store a blob which the model validation would refuse.
      def validate_content!(file)
        return unless Decidim::UploadContentTypes.format(detect_content_type(file)) == :svg

        return if Decidim::SvgContentValidator.validate(file_contents(file)) == :valid

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.file_upload.errors.unsafe_content")
      end

      def detect_content_type(file)
        tempfile = file.respond_to?(:tempfile) ? file.tempfile : file.path
        Marcel::MimeType.for(tempfile, name: sanitized_filename(file)) || file.content_type
      end

      def file_contents(file)
        io = file.respond_to?(:tempfile) ? file.tempfile : file
        contents = io.read
        io.rewind
        contents
      end

      # Invalid byte sequences cannot be stored in the database, as they raise
      # `PG::CharacterNotInRepertoire` when the blob is inserted.
      def sanitized_filename(file)
        name = File.basename(file.original_filename)
        name.valid_encoding? ? name : name.scrub
      end

      def current_organization
        context[:current_organization]
      end
    end
  end
end
