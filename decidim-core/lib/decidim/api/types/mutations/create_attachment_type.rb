# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment"
      type Decidim::Core::AttachmentType

      argument :attributes, AttachmentAttributes, description: "input attributes to create an attachment", required: true

      def resolve(attributes:)
        form = form(::Decidim::Admin::AttachmentForm).from_params(attributes.to_h, attached_to: object)
                                                     .with_context(
                                                       current_component: context[:current_component],
                                                       current_organization: context[:current_organization],
                                                       current_user: context[:current_user]
                                                     )
        handle_form_submission do
          ::Decidim::Admin::CreateAttachment.call(form, attached_to: object)
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :attachment, object, context, scope: :admin)
      end
    end
  end
end
