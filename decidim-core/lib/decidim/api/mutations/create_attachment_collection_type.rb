# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentCollectionType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment collection"
      type Decidim::Core::AttachmentCollectionType

      argument :attributes, AttachmentCollectionAttributes, description: "Input attributes to create an attachment collection", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::AttachmentCollectionForm).from_params(params, collection_for: object)

        Decidim::Admin::CreateAttachmentCollection.call(form, object) do
          on(:ok, attachment_collection) do
            return attachment_collection
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:create, :attachment_collection, nil, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :name)
        validate_multiple_locales(attributes, :description)

        key = attributes.key

        attributes = attributes.to_h.merge(key:)

        attributes[:name] = attributes.to_h.fetch(:name, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
