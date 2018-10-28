# frozen_string_literal: true

class CreateDecidimHashtags < ActiveRecord::Migration[5.2]
  def self.up
    create_table :decidim_hashtags do |t|
      t.references :decidim_organization

      t.string :name, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :decidim_hashtags
  end
end
