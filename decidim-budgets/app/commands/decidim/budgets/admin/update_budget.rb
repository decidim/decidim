# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user updates a Budget
      # from the admin panel.
      class UpdateBudget < Decidim::Commands::UpdateResource
        fetch_form_attributes :scope, :title, :weight, :description, :total_budget

        protected

        def extra_params = { visibility: "all" }
      end
    end
  end
end
