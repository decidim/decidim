# This migration comes from decidim_results (originally 20170612101951)
# frozen_string_literal: true

class MigrateResultsCategory < ActiveRecord::Migration[5.1]
  def change
    # Create categorizations ensuring database integrity
    execute('
      INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type, created_at, updated_at)
        SELECT decidim_category_id, decidim_results_results.id, \'Decidim::Results::Result\', NOW(), NOW()
        FROM decidim_results_results
        INNER JOIN decidim_categories ON decidim_categories.id = decidim_results_results.decidim_category_id
    ')
    # Remove unused column
    remove_column :decidim_results_results, :decidim_category_id
  end
end
