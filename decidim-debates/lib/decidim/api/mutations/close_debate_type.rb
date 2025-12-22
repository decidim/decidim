# frozen_string_literal: true

module Decidim
  module Debates
    class CloseDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "CloseDebate"

      description "Closes a debate"
      type Decidim::Debates::DebateType

      argument :attributes, CloseDebateAttributes, description: "Input attributes for closing a debate", required: true
      argument :locale, GraphQL::Types::String, "The locale to use for the mutation", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = {
          id: object.id,
          conclusions: attributes.to_h.fetch(:conclusions, "")
        }

        form = form(Decidim::Debates::CloseDebateForm).from_params(params)

        Decidim::Debates::CloseDebate.call(form) do
          on(:ok) do |debate|
            return debate.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless [
          super,
          allowed_to?(:close, :debate, object, context),
          !object.closed?
        ].all?

        true
      end
    end
  end
end
