# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment"
      type Decidim::Core::AttachmentType

      argument :attributes, AttachmentAttributes, description: "input attributes to create an attachment", required: true

      def resolve(attributes:)
        form = Admin::AttachmentForm.from_params(attributes.to_h.merge(file: attributes.file.blob.signed_id))
                                    .with_context(
                                      current_component: context[:current_component],
                                      current_organization: context[:current_organization],
                                      current_user: context[:current_user],
                                      attached_to: object
                                    )

        attachment = nil
        Admin::CreateAttachment.call(form, object) do
          on(:ok) do
            attachment = @attachment
          end
        end
        return attachment if attachment.present?

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachments.create.error")
        )
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :attachment, object, context, scope: :admin)
      end
    end
  end
end
