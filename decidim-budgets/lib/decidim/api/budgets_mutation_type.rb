# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "BudgetsMutation"
      description "Budgets of a component."

      # field :budget, type: Decidim::Budgets::BudgetMutationType, description: "Mutates a budget", null: true do
      #   argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
      # end

      field :create_budget, Decidim::Budgets::BudgetType, null: false do
        description "create budget for the currnt budgets component
A typical mutation would be like:

```
mutation{
  component(id: 123) {
    ... on BudgetsMutation {
      createBudget(
        attributes:{
          title: {fi: 'Your title'},
          description: {fi: 'Your description' },
          wight: 10,
          scope_id: 2,
          total_budget: 12345
        }
      ){
        id
      }
    }
  }
}
```
        "

        argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
      end

      field :update_budget, type: Decidim::Budgets::BudgetType, description: "Mutates a budget", null: true do
        description "Edit budget.

A typical mutation would be like:

```
mutation{
  component(id: 123) {
    ... on BudgetsMutation {
        updateBudget(
          attributes: {
            title: {en: 'Dummy title'}
          },
          id: 234
        ){
          id
        }
    }
  }
}
```
"
        argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true
        argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
      end

      field :soft_delete, type: Decidim::Budgets::BudgetType, null: true do
        description "Delete budget

A typical mutation would be like:

```
mutation{
  component(id: 123) {
    ... on BudgetsMutation {
      soft_Delete(id: 234){
        id
      }
    }
  }
}
```
"
        argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
      end

      def budget(id:)
        Decidim::Budgets::Budget.find_by(id: id, component: object)
      end

      def create_budget(attributes:)
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

      def update_budget(attributes:, id:)
        form = Decidim::Budgets::Admin::BudgetForm.from_params(
          weight: attributes.weight,
          title: json_value(attributes.title),
          description: json_value(attributes.description),
          total_budget: attributes.total_budget.to_i,
          decidim_scope_id: attributes.scope_id
        ).with_context(
          current_component: object,
          current_organization: object.organization,
          current_user: context[:current_user]
        )
        Decidim::Budgets::Admin::UpdateBudget.call(form, budget(id:)) do
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

      def soft_delete(id:)
        puts "CALLED SOFT DELETE"
        budget = budget(id:)
        Decidim::Commands::SoftDeleteResource.call(budget, context[:current_user]) do
          on(:ok) do
            return budget
          end

          on(:invalid) do
            I18n.t("soft_delete.invalid", scope: trashable_i18n_scope, resource_name: human_readable_resource_name)
          end
        end
      end

      def self.authorized?(object, context)
        puts context.to_h.inspect

        return
        super && allowed_to?(:create, :proposal_answer, object, context, scope: :admin)
      end

      private

      def trashable_deleted_resource_type
        :budget
      end

      def trashable_deleted_resource
        @trashable_deleted_resource ||= Budget.with_deleted.find_by(component: current_component, id: params[:id])
      end
    end
  end
end
