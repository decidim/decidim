# frozen_string_literal: true

class ChangeBudgetColumnsToBigint < ActiveRecord::Migration[7.1]
  def change
    change_column :decidim_budgets_budgets, :total_budget, :bigint
    change_column :decidim_budgets_projects, :budget_amount, :bigint
  end
end
