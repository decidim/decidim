# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user destroys a Budget
      # from the admin panel.
      class DestroyBudget < Decidim::Commands::DestroyResource
        private

        def invalid? = resource.projects.present?

        def extra_params = { visibility: "all" }
      end
    end
  end
end
