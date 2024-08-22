# frozen_string_literal: true

class AddDeletedAtToDecidimComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_components, :deleted_at, :datetime
    add_index :decidim_components, :deleted_at
  end
end
