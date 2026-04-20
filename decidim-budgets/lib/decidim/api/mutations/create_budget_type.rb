# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateBudgetType < Decidim::Api::Types::BaseMutation
      description "Creates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::BudgetForm).from_params(params)

        Admin::CreateBudget.call(form) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:create, :budget, object, { current_user:, current_component: }, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
