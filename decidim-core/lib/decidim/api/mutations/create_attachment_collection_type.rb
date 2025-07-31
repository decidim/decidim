# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentCollectionType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment collection"
      type Decidim::Core::AttachmentCollectionType

      argument :attributes, AttachmentCollectionAttributes, description: "input attributes to create an attachment collection", required: true

      def resolve(attributes:)
        key = attributes.key || attributes.slug
        form = Admin::AttachmentCollectionForm.from_params(attributes.to_h.merge(key:))
                                              .with_context(
                                                current_component: context[:current_component],
                                                current_organization: context[:current_organization],
                                                current_user: context[:current_user],
                                                collection_for: object
                                              )
        attachment_collection = nil
        Decidim::Admin::CreateAttachmentCollection.call(form, object) do
          on(:ok) do
            attachment_collection = @attachment_collection
          end
        end
        return attachment_collection if attachment_collection.present?

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachment_collections.create.error")
        )
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :attachment_collection, object, context, scope: :admin)
      end
    end
  end
end
