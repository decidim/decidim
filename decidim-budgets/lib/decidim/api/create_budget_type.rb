# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateBudgetType < Decidim::Api::Types::BaseMutation
      description "Creates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to create a budget", required: true

      def resolve(attributes:)
        form = Decidim::Budgets::Admin::BudgetForm.from_params(attributes.to_h)
                                                  .with_context(
                                                    current_component: object,
                                                    current_organization: object.organization,
                                                    current_user: context[:current_user]
                                                  )

        Decidim::Budgets::Admin::CreateBudget.call(form) do
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

      def authorized?(attributes:)
        super && allowed_to?(:create, :budget, object, context, scope: :admin)
      end
    end
  end
end
