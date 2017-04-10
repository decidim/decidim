class RemoveNotNullReferenceResults < ActiveRecord::Migration[5.0]
  def change
    change_column_null :decidim_results_results, :reference, true
  end
end
