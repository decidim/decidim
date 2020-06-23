# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user destroys a Budget
      # from the admin panel.
      class DestroyBudget < Rectify::Command
        def initialize(budget, current_user)
          @budget = budget
          @current_user = current_user
        end

        # Destroys the budget if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_budget!

          broadcast(:ok, budget)
        end

        private

        attr_reader :budget, :current_user

        def destroy_budget!
          Decidim.traceability.perform_action!(
            :delete,
            budget,
            current_user,
            visibility: "all"
          ) do
            budget.destroy!
          end
        end
      end
    end
  end
end
