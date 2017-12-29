# This migration comes from decidim_budgets (originally 20170130101825)
# frozen_string_literal: true

class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_budgets_line_items do |t|
      t.references :decidim_order, index: true
      t.references :decidim_project, index: true
    end

    add_index :decidim_budgets_line_items, [:decidim_order_id, :decidim_project_id], unique: true, name: "decidim_budgets_line_items_order_project_unique"
  end
end
