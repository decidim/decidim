# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates an Budget
      # from the admin panel.
      class CreateBudget < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the budget if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_budget!

          broadcast(:ok, budget)
        end

        private

        attr_reader :form, :budget

        def create_budget!
          attributes = {
            component: form.current_component,
            title: form.title,
            weight: form.weight,
            description: form.description,
            total_budget: form.total_budget
          }

          @budget = Decidim.traceability.create!(
            Budget,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
