# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentType < Decidim::Api::Types::BaseMutation
      include Decidim::Core::FileUpload

      description "Creates an attachment"
      type Decidim::Core::AttachmentType

      # Managing attachments is an administrative action, so the OAuth token must
      # have been granted the administrative scopes, in the same way as the upload
      # mutation and the existing result and project mutations. These scopes also
      # make `api_scope` return `:admin`, so the permission check is done against
      # the administrative permissions.
      required_scopes "api:read", "api:write", "admin:read", "admin:write"

      argument :attributes, AttachmentAttributes, description: "Input attributes to create an attachment", required: true

      def resolve(attributes:)
        params = extract_from(attributes)
        form = form(Admin::AttachmentForm).from_params(params, attached_to: object)

        Admin::CreateAttachment.call(form, object) do
          on(:ok, attachment) do
            return attachment
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        context[:attached_to] = object

        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:create, :attachment, nil, context)

        true
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.merge(
          file: attributes.file && create_blob!(attributes.file).signed_id,
          attachment_collection_id: attributes.collection&.id_value
        )

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
