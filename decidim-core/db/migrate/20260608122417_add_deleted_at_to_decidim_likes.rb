# frozen_string_literal: true

class AddDeletedAtToDecidimLikes < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_likes, :deleted_at, :datetime
    add_index :decidim_likes, :deleted_at
  end
end
