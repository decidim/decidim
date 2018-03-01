# This migration comes from decidim_budgets (originally 20170410074214)
# frozen_string_literal: true

class RemoveNotNullReferenceBudgets < ActiveRecord::Migration[5.0]
  def change
    change_column_null :decidim_budgets_projects, :reference, true
  end
end
