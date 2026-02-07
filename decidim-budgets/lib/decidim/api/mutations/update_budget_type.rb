# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateBudgetType < Decidim::Api::Types::BaseMutation
      description "Updates a budget"
      type Decidim::Budgets::BudgetType

      argument :attributes, BudgetAttributes, description: "input attributes to update a budget", required: true
      argument :id, GraphQL::Types::ID, "The ID of the budget", required: true

      def resolve(attributes:, id:) # rubocop:disable Lint/UnusedMethodArgument
        form_attrs = attributes.to_h.reverse_merge(
          weight: budget.weight,
          title: budget.title,
          description: budget.description,
          total_budget: budget.total_budget,
          decidim_scope_id: budget.scope&.id
        )

        form = form(Admin::BudgetForm).from_params(form_attrs)

        Admin::UpdateBudget.call(form, budget) do
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
        unless super && allowed_to?(:update, :budget, budget(id), context, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def budget(id = nil)
        context[:budget] ||= begin
          id ||= arguments[:id]
          Decidim::Budgets::Budget.find_by(id:, component: object)
        end
      end
    end
  end
end
