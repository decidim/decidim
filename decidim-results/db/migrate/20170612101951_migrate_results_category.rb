# frozen_string_literal: true

class MigrateResultsCategory < ActiveRecord::Migration[5.1]
  def change
    records = ActiveRecord::Base.connection.execute("SELECT id, decidim_category_id FROM decidim_results_results")
    values = records.map do |record|
      "(#{record[:id]}, #{record[:decidim_category_id]}, 'Decidim::Results::Result')"
    end
    if values.any?
      ActiveRecord::Base.connection.execute(
        "INSERT INTO decidim_categorizations(decidim_category_id, categorizable_id, categorizable_type) VALUES #{values.join(', ')}"
      )
    end
    remove_column :decidim_results_results, :decidim_category_id
  end
end
