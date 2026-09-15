# frozen_string_literal: true

class AddDeletedAtToDecidimCoauthorships < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_coauthorships, :deleted_at, :datetime
    add_index :decidim_coauthorships, :deleted_at
  end
end
