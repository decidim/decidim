# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateBudgetType < Decidim::Api::Types::BaseMutation
      include Decidim::ApiResponseHelper

      description "Updates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
      argument :id, GraphQL::Types::ID, "The ID of the budget", required: true

      def resolve(attributes:, id:)
        budget = Decidim::Budgets::Budget.find_by(id:, component: object)
        return unless self.class.allowed_to?(:update, :budget, budget, context, scope: :admin)

        form = Decidim::Budgets::Admin::BudgetForm.from_params(
          weight: attributes.weight || budget.weight,
          title: json_value(attributes.title),
          description: json_value(attributes.description),
          total_budget: attributes.total_budget.to_i,
          decidim_scope_id: attributes.scope_id
        ).with_context(
          current_component: object,
          current_organization: object.organization,
          current_user: context[:current_user]
        )

        Decidim::Budgets::Admin::UpdateBudget.call(form, budget) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end
      end

      def authorized?(attributes:, id:)
        budget = Decidim::Budgets::Budget.find_by(id:, component: object)

        super && allowed_to?(:update, budget, budget, context, scope: :admin)
      end
    end
  end
end
