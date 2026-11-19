# frozen_string_literal: true

class RemoveWeightFromDecidimBudgetsBudgets < ActiveRecord::Migration[8.1]
  def change
    remove_column :decidim_budgets_budgets, :weight, :integer, null: false, default: 0
  end
end
