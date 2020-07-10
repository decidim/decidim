# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a budget in the Decidim::Budgets component.
    class Budget < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Traceable
      include Loggable

      component_manifest_name "budgets"

      has_many :projects, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Project", inverse_of: :budget, dependent: :destroy
      has_many :orders, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Order", inverse_of: :budget, dependent: :destroy

      delegate :participatory_space, :manifest, :settings, to: :component

      def self.log_presenter_class_for(_log)
        Decidim::Budgets::AdminLog::BudgetPresenter
      end
    end
  end
end
