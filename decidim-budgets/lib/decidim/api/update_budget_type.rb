# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateBudgetType < Decidim::Api::Types::BaseMutation
      description "Updates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
      argument :id, GraphQL::Types::ID, "The ID of the budget", required: true

      def resolve(attributes:, id:)
        budget = Decidim::Budgets::Budget.find_by(id:, component: object)
        return unless self.class.allowed_to?(:update, :budget, budget, context, scope: :admin)

        form_attrs = attributes.to_h.reverse_merge(
          weight: budget.weight,
          title: budget.title,
          description: budget.description,
          total_budget: budget.total_budget,
          decidim_scope_id: budget.scope&.id
        )

        form = Decidim::Budgets::Admin::BudgetForm.from_params(form_attrs).with_context(
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
