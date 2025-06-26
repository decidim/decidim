# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateBudgetType < Decidim::Api::Types::BaseMutation
      description "Creates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true

      def resolve(attributes:)
        form = Decidim::Budgets::Admin::BudgetForm.from_params(
          weight: attributes.weight,
          title: json_value(attributes.title),
          description: json_value(attributes.description),
          total_budget: attributes.total_budget.to_i,
          decidim_scope_id: attributes.scope_id.to_i
        ).with_context(
          current_component: object,
          current_organization: object.organization,
          current_user: context[:current_user]
        )

        Decidim::Budgets::Admin::CreateBudget.call(form) do
          on(:ok, budget) do
            return budget
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end
      end

      def self.authorized?(object, context)
        super && allowed_to?(:create, :budget, object, context, scope: :admin)
      end
    end
  end
end
