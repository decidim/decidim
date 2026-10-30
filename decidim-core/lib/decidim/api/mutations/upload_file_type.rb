# frozen_string_literal: true

module Decidim
  module Core
    class UploadFileType < Decidim::Api::Types::BaseMutation
      include Decidim::Api::GraphqlPermissions
      include Decidim::Core::FileUpload

      description "Upload a file via multipart form"

      # The permission system only checks the role of the user, so the scopes
      # granted to the OAuth token are checked here too. Uploading a file is an
      # administrative action, so only the administrative scopes are accepted: a
      # token granted the participant scopes cannot upload files, even when it has
      # `api:write`. These scopes also make `api_scope` return `:admin`, so the
      # permission check is done against the administrative permissions.
      required_scopes "api:read", "api:write", "admin:read", "admin:write"

      argument :file, Decidim::Api::Types::BaseUpload, description: "File being uploaded", required: true

      field :blob, Decidim::Core::BlobType, description: "Blob of the uploaded file", null: true

      def resolve(file:)
        { blob: create_blob!(file) }
      end

      def authorized?(file:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:create, :blob, nil, context)

        true
      end
    end
  end
end
