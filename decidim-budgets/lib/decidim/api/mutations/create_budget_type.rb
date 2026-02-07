# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateBudgetType < Decidim::Api::Types::BaseMutation
      description "Creates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true

      def resolve(attributes:)
        form = form(Admin::BudgetForm).from_params(attributes.to_h)

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
    end
  end
end
