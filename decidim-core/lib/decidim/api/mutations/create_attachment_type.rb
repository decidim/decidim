# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment"
      type Decidim::Core::AttachmentType

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
        previous_scope = context[:scope]
        context[:scope] = :admin

        context[:attached_to] = object

        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:create, :attachment, nil, context)

        true
      ensure
        context[:scope] = previous_scope
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.merge(
          file: attributes.file&.blob&.signed_id,
          attachment_collection_id: attributes.collection&.id_value
        )

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
