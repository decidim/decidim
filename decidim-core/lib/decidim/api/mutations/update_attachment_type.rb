# frozen_string_literal: true

module Decidim
  module Core
    class UpdateAttachmentType < Decidim::Api::Types::BaseMutation
      include Decidim::Core::FileUpload

      description "Updates an attachment"
      type Decidim::Core::AttachmentType

      # Managing attachments is an administrative action, so the OAuth token must
      # have been granted the administrative scopes, in the same way as the upload
      # mutation and the existing result and project mutations. These scopes also
      # make `api_scope` return `:admin`, so the permission check is done against
      # the administrative permissions.
      required_scopes "api:read", "api:write", "admin:read", "admin:write"

      argument :attributes, AttachmentAttributes, description: "Input attributes to update an attachment", required: true
      argument :id, GraphQL::Types::ID, "The ID of the attachment", required: true

      def resolve(attributes:, id:)
        return GraphQL::ExecutionError.new(I18n.t("decidim.admin.attachments.update.error")) unless attachment(id)

        params = extract_from(attributes)
        form = form(Admin::AttachmentForm).from_params(params, attached_to: object)

        Decidim::Admin::UpdateAttachment.call(attachment, form) do
          on(:ok) do
            return attachment.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, id:)
        unless super && allowed_to?(:update, :attachment, attachment(id), context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def attachment(id = nil)
        @attachment ||= begin
          id ||= arguments[:id]
          object.attachments.find(id)
        end
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        file_attribute = (attributes.file && create_blob!(attributes.file).signed_id) ||
                         attachment.file&.blob&.signed_id

        # An omitted `collection` keeps the collection the attachment has, while an
        # explicit null removes the association, so the two cases have to be told
        # apart.
        attachment_attribute = if attributes.to_h.has_key?(:collection)
                                 attributes.collection&.id_value
                               else
                                 attachment.attachment_collection&.id
                               end

        {
          # The `id` makes the form persisted, and the `link` is kept for the
          # attachments which are a link instead of a file (they have no blob to
          # fall back to), otherwise the form would be treated as a new attachment
          # without a file and the update would be rejected. A new file replaces
          # the link, so the link is only kept when no file is sent.
          id: attachment.id,
          title: attachment.title,
          description: attachment.description,
          # The stored values are kept when the client does not send them, so the
          # input objects have no default for `weight` and an omitted weight does
          # not reorder the attachment.
          weight: attachment.weight,
          file: file_attribute,
          link: attributes.file ? nil : attachment.link,
          attachment_collection_id: attachment_attribute
        }.merge(
          attributes.to_h.slice(:title, :description, :weight)
        )
      end
    end
  end
end
