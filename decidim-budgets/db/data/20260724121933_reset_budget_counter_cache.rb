# frozen_string_literal: true

class ResetBudgetCounterCache < ActiveRecord::Migration[8.1]
  def up
    Decidim::Budgets::Budget.find_each do |budget|
      Decidim::Budgets::Budget.reset_counters(budget.id, :projects_count)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
