# frozen_string_literal: true

class IndexForeignKeysInDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_accountability_results, :external_id
  end
end
