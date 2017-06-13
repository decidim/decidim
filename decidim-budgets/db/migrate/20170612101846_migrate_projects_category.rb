# frozen_string_literal: true

class MigrateProjectsCategory < ActiveRecord::Migration[5.1]
  def change
    # Ensure database integrity updating projects with an invalid category
    ActiveRecord::Base.connection.execute('
      UPDATE decidim_budgets_projects SET decidim_category_id = NULL where id IN (
        SELECT t.id FROM decidim_budgets_projects as t WHERE t.decidim_category_id NOT IN (
          SELECT c.id FROM decidim_categories as c
        )
      )
    ')
    # Create categorizations
    ActiveRecord::Base.connection.execute('
      INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type, created_at, updated_at)
        SELECT decidim_category_id, id, \'Decidim::Budgets::Project\', NOW(), NOW()
        FROM decidim_budgets_projects
        WHERE decidim_category_id IS NOT NULL
    ')
    # Remove unused column
    remove_column :decidim_budgets_projects, :decidim_category_id
  end
end
