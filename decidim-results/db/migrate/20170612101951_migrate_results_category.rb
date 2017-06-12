# frozen_string_literal: true

class MigrateResultsCategory < ActiveRecord::Migration[5.1]
  def change
    Decidim::Results::Result.find_each do |result|
      Decidim::Categorization.create!(
        decidim_category_id: result.category.id,
        categorizable: result
      )
    end
    remove_column :decidim_results_results, :decidim_category_id
  end
end
