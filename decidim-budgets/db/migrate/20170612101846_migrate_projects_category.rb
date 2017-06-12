# frozen_string_literal: true

class MigrateProjectsCategory < ActiveRecord::Migration[5.1]
  def change
    records = ActiveRecord::Base.connection.execute("SELECT id, decidim_category_id FROM decidim_budgets_projects")
    values = records.map do |record|
      "(#{record[:id]}, #{record[:decidim_category_id]}, 'Decidim::Budgets::Project')"
    end
    if values.any?
      ActiveRecord::Base.connection.execute(
        "INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type) VALUES #{values.join(', ')}"
      )
    end
    remove_column :decidim_budgets_projects, :decidim_category_id
  end
end
