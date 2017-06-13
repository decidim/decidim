# frozen_string_literal: true

class MigrateResultsCategory < ActiveRecord::Migration[5.1]
  def change
    # Ensure database integrity updating results with an invalid category
    ActiveRecord::Base.connection.execute("""
      UPDATE decidim_results_results SET decidim_category_id = NULL where id IN (
        SELECT t.id FROM decidim_results_results as t WHERE t.decidim_category_id NOT IN (
          SELECT c.id FROM decidim_categories as c
        )
      )
    """)
    # Create categorizations
    ActiveRecord::Base.connection.execute("""
      INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type, created_at, updated_at)
        SELECT decidim_category_id, id, 'Decidim::Results::Result', NOW(), NOW()
        FROM decidim_results_results
        WHERE decidim_category_id IS NOT NULL
    """)
    # Remove unused column
    remove_column :decidim_results_results, :decidim_category_id
  end
end
