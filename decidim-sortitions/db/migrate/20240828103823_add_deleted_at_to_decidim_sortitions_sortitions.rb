# frozen_string_literal: true

class AddDeletedAtToDecidimSortitionsSortitions < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_sortitions_sortitions, :deleted_at, :datetime
    add_index :decidim_sortitions_sortitions, :deleted_at
  end
end
