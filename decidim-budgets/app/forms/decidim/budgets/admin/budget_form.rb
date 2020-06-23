# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update budgets from Decidim's admin panel.
      class BudgetForm < Decidim::Form
        include TranslatableAttributes

        mimic :budget

        translatable_attribute :title, String
        attribute :weight, Integer, default: 0
        translatable_attribute :description, String
        attribute :total_budget, Integer, default: 0

        validates :title, translatable_presence: true
        validates :weight, :total_budget, numericality: { greater_than_or_equal_to: 0 }
      end
    end
  end
end
