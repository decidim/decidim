# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a budget in the Decidim::Budgets component.
    class Budget < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::ScopableResource
      include Decidim::HasComponent
      include Decidim::Searchable
      include Traceable
      include Loggable

      component_manifest_name "budgets"

      has_many :projects, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Project", inverse_of: :budget, dependent: :destroy
      has_many :orders, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Order", inverse_of: :budget, dependent: :destroy

      delegate :participatory_space, :manifest, :settings, to: :component

      searchable_fields({
                          participatory_space: { component: :participatory_space },
                          A: :title,
                          D: [:description, :total_budget]
                        },
                        index_on_create: ->(budget) { budget.visible? },
                        index_on_update: ->(budget) { budget.visible? })

      def self.log_presenter_class_for(_log)
        Decidim::Budgets::AdminLog::BudgetPresenter
      end
    end
  end
end
