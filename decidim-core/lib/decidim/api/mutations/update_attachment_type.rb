# frozen_string_literal: true

module Decidim
  module Core
    class UpdateAttachmentType < Decidim::Api::Types::BaseMutation
      description "Updates an attachment"
      type Decidim::Core::AttachmentType

      argument :attributes, AttachmentAttributes, description: "input attributes to update an attachment", required: true
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
        context[:attachment] ||= begin
          id ||= arguments[:id]
          object.attachments.find(id)
        end
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        file_attribute = attributes.file&.blob&.signed_id ||
                         attachment.file&.blob&.signed_id

        attachment_attribute = attributes.collection&.id_value || attachment.attachment_collection&.id
        {
          title: attachment.title,
          description: attachment.description,
          weight: attachment.weight,
          file: file_attribute,
          attachment_collection_id: attachment_attribute
        }.merge(
          attributes.to_h.slice(:title, :description, :weight)
        )
      end
    end
  end
end
