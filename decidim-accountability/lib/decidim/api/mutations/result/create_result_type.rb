# frozen_string_literal: true

module Decidim
  module Accountability
    class CreateResultType < Decidim::Api::Types::BaseMutation
      description "Creates a result"
      type Decidim::Accountability::ResultType

      argument :attributes, ResultAttributes, description: "input attributes of a result", required: true

      def resolve(attributes:)
        form = Admin::ResultForm.from_params(attributes.to_h).with_context(
          current_component: object,
          current_user: context[:current_user],
          current_organization: object.organization
        )
        handle_form_submission do
          Admin::CreateResult.call(form)
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :result, object, context, scope: :admin)
      end
    end
  end
end
