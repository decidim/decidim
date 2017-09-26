# frozen_string_literal: true

class AddIndexToAccountabilityResultsOnExternalId < ActiveRecord::Migration[5.0]
  def change
    add_index :decidim_accountability_results, [:decidim_feature_id, :external_id], unique: true, name: :decidim_accountability_results_on_external_id
  end
end
