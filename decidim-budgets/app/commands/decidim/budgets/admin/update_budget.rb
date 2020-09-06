# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user updates a Budget
      # from the admin panel.
      class UpdateBudget < Rectify::Command
        def initialize(form, budget)
          @form = form
          @budget = budget
        end

        # Updates the budget if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_budget!

          broadcast(:ok, budget)
        end

        private

        attr_reader :form, :budget

        def update_budget!
          attributes = {
            title: form.title,
            weight: form.weight,
            description: form.description,
            total_budget: form.total_budget
          }

          Decidim.traceability.update!(
            budget,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
