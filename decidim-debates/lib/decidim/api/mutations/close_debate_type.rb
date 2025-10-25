# frozen_string_literal: true

module Decidim
  module Debates
    class CloseDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "CloseDebate"

      description "Closes a debate"
      type Decidim::Debates::DebateType

      argument :attributes, CloseDebateAttributes, description: "input attributes for closing a debate", required: true

      def resolve(attributes:)
        conclusions = attributes.to_h.fetch(:conclusions, {})
        params = {
          id: object.id,
          conclusions: conclusions
        }

        form = Decidim::Debates::CloseDebateForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_user: current_user,
          current_organization: current_user.organization
        )

        Decidim::Debates::CloseDebate.call(form) do
          on(:ok) do |debate|
            return debate
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.debates.close.invalid")
          )
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:close, :debate, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
