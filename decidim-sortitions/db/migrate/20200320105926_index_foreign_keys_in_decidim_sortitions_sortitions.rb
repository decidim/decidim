# frozen_string_literal: true

class IndexForeignKeysInDecidimSortitionsSortitions < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_sortitions_sortitions, :cancelled_by_user_id
  end
end
