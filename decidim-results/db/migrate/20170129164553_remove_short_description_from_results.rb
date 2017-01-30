class RemoveShortDescriptionFromResults < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_results_results, :short_description
  end
end
