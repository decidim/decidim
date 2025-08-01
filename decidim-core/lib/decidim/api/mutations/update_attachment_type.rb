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

        form_params = params_from_attributes(attributes)
        form = Admin::AttachmentForm.from_params(form_params).with_context(
          current_component: context[:current_component],
          current_organization: context[:current_organization],
          current_user: context[:current_user],
          attached_to: object
        )

        status = nil
        Decidim::Admin::UpdateAttachment.call(attachment, form) do
          on(:ok) do
            status = :ok
          end
        end
        return attachment.reload if status == :ok

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachments.update.error")
        )
      end

      def authorized?(attributes:, id:)
        super && allowed_to?(:update, :attachment, attachment(id), context, scope: :admin)
      end

      private

      def attachment(id = nil)
        context[:attachment] ||= begin
          id ||= arguments[:id]
          object.attachments.find_by(id:)
        end
      end

      def params_from_attributes(attributes)
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
