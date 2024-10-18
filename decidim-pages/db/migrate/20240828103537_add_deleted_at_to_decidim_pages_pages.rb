# frozen_string_literal: true

class AddDeletedAtToDecidimPagesPages < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_pages_pages, :deleted_at, :datetime
    add_index :decidim_pages_pages, :deleted_at
  end
end
