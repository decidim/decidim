# frozen_string_literal: true

class ResetBudgetCounterCache < ActiveRecord::Migration[8.1]
  class Budget < ApplicationRecord
    self.table_name = :decidim_budgets_budgets
  end

  class Project < ApplicationRecord
    self.table_name = :decidim_budgets_projects
  end

  def up
    Budget.find_each do |budget|
      # Trashed (soft-deleted) projects are excluded from `budget.projects`, so they
      # must not be included in the counter cache.
      count = Project.where(decidim_budgets_budget_id: budget.id, deleted_at: nil).count
      budget.update_column(:projects_count, count) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
