# frozen_string_literal: true

class CreateDecidimEndorsements < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_endorsements do |t|
      t.references :resource, polymorphic: true
      t.references :decidim_author, polymorphic: true, index: { name: "idx_endorsements_authors" }
      t.integer :decidim_user_group_id, foreign_key: true
      t.timestamps
      t.index [:resource_type, :resource_id, :decidim_author_type, :decidim_author_id, :decidim_user_group_id], name: "idx_endorsements_rsrcs_and_authors", unique: true
    end
  end
end
