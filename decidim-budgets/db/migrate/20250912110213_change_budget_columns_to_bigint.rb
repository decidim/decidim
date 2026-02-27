# frozen_string_literal: true

class ChangeBudgetColumnsToBigint < ActiveRecord::Migration[7.1]
  def up
    change_column :decidim_budgets_budgets, :total_budget, :bigint
    change_column :decidim_budgets_projects, :budget_amount, :bigint
  end

  def down
    change_column :decidim_budgets_budgets, :total_budget, :integer
    change_column :decidim_budgets_projects, :budget_amount, :integer
  end
end
