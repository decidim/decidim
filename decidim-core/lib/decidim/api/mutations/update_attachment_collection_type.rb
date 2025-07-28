# frozen_string_literal: true

module Decidim
  module Core
    class UpdateAttachmentCollectionType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment collection"
      type Decidim::Core::AttachmentCollectionType

      argument :attributes, AttachmentCollectionAttributes, description: "input attributes to create an attachment collection", required: true
      argument :id, GraphQL::Types::ID, "The ID of the attachment collection", required: true

      def resolve(attributes:, id:)
        return GraphQL::ExecutionError.new(I18n.t("decidim.admin.attachments.update.error")) unless attachment_collection(id)

        form_attrs = attributes.to_h.reverse_merge(
          description: attachment_collection.description,
          name: attachment_collection.name,
          key: attachment_collection.key
        )
        form = Admin::AttachmentCollectionForm.from_params(form_attrs.merge(current_user: context[:current_user]))
                                              .with_context(
                                                current_component: context[:current_component],
                                                current_organization: context[:current_organization],
                                                current_user: context[:current_user],
                                                collection_for: object
                                              )

        Decidim::Admin::UpdateAttachmentCollection.call(attachment_collection, form) do
          on(:ok) do
            return @attachment_collection.reload
          end
        end

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachment_collections.update.error")
        )
      end

      def authorized?(attributes:, id:)
        super && allowed_to?(:update, :attachment_collection, attachment_collection(id), context, scope: :admin)
      end

      private

      def attachment_collection(id = nil)
        context[:attachment_collection] ||= begin
          id ||= arguments[:id]
          object.attachment_collections.find_by(id:)
        end
      end
    end
  end
end
