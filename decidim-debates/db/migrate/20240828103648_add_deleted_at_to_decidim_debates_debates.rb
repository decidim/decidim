# frozen_string_literal: true

class AddDeletedAtToDecidimDebatesDebates < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_debates_debates, :deleted_at, :datetime
    add_index :decidim_debates_debates, :deleted_at
  end
end
