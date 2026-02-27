# frozen_string_literal: true

class ChangeBudgetColumnsToBigint < ActiveRecord::Migration[7.1]
  def up
    change_column :decidim_budgets_budgets, :total_budget, :bigint
    change_column :decidim_budgets_projects, :budget_amount, :bigint
  end

  def down
    budget_overflow = select_value(<<~SQL.squish)
      SELECT 1 FROM decidim_budgets_budgets
      WHERE total_budget > 2147483647 OR total_budget < -2147483648
      LIMIT 1
    SQL
    project_overflow = select_value(<<~SQL.squish)
      SELECT 1 FROM decidim_budgets_projects
      WHERE budget_amount > 2147483647 OR budget_amount < -2147483648
      LIMIT 1
    SQL

    raise ActiveRecord::IrreversibleMigration, "Cannot safely convert bigint budgets back to integer: out-of-range values exist" if budget_overflow || project_overflow

    change_column :decidim_budgets_budgets, :total_budget, :integer
    change_column :decidim_budgets_projects, :budget_amount, :integer
  end
end
