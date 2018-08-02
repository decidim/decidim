# frozen_string_literal: true

class CreateDecidimHashtagggings < ActiveRecord::Migration[5.2]
  def self.up
    create_table :decidim_hashtaggings do |t|
      t.references :decidim_hashtag, index: true
      t.references :decidim_hashtaggable, polymorphic: true, index: { name: "idx_hashtaggins_on_hashtaggable_type_and_hashtaggable_id" }
    end
    add_index :decidim_hashtaggings, %w(decidim_hashtaggable_id decidim_hashtaggable_type),
              name: "index_hashtaggings_hashtaggable_id_hashtaggable_type"
  end

  def self.down
    drop_table :decidim_hashtaggings
  end
end
