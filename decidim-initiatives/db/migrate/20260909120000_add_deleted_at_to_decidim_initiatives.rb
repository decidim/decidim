# frozen_string_literal: true

class AddDeletedAtToDecidimInitiatives < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_initiatives, :deleted_at, :datetime
    add_index :decidim_initiatives, :deleted_at
  end
end
