# frozen_string_literal: true

module Decidim
  module Core
    class UpdateAttachmentCollectionType < Decidim::Api::Types::BaseMutation
      description "Updates an attachment collection"
      type Decidim::Core::AttachmentCollectionType

      argument :attributes, AttachmentCollectionAttributes, description: "Input attributes to update an attachment collection", required: true
      argument :id, GraphQL::Types::ID, "The ID of the attachment collection", required: true

      def resolve(attributes:, id:)
        return GraphQL::ExecutionError.new(I18n.t("decidim.admin.attachments.update.error")) unless attachment_collection(id)

        params = extract_from(attributes)

        form = form(Admin::AttachmentCollectionForm).from_params(params, collection_for: object)

        Decidim::Admin::UpdateAttachmentCollection.call(attachment_collection, form) do
          on(:ok, attachment_collection) do
            return attachment_collection.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, id:)
        unless super && allowed_to?(:update, :attachment_collection, attachment_collection(id), context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def attachment_collection(id = nil)
        context[:attachment_collection] ||= begin
          id ||= arguments[:id]
          object.attachment_collections.find(id)
        end
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :name)
        validate_multiple_locales(attributes, :description)

        key = attributes[:key].presence || attributes[:slug] || attachment_collection.key

        {
          key:,
          description: attachment_collection.description,
          name: attachment_collection.name,
          weight: attachment_collection.weight
        }.merge(attributes.to_h.slice(:name, :description, :weight))
      end
    end
  end
end
