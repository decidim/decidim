# frozen_string_literal: true

class RenameBudgetToBudgetAmmount < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_budgets_projects, :budget, :budget_amount
  end
end
