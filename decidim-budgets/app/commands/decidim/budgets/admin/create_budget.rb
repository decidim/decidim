# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates an Budget
      # from the admin panel.
      class CreateBudget < Decidim::Commands::CreateResource
        fetch_form_attributes :component, :title, :weight, :description, :total_budget

        private

        def extra_params = { visibility: "all" }

        def resource_class = Decidim::Budgets::Budget
      end
    end
  end
end
