# frozen_string_literal: true

class CreateDecidimAmendments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_amendments do |t|
      t.references :decidim_user, null: false
      t.references :decidim_amendable, polymorphic: true, index: false
      t.references :decidim_emendation, polymorphic: true, index: false
      t.string :state, index: true
      t.timestamps
    end

    add_index :decidim_amendments,
              [:decidim_user_id, :decidim_amendable_id, :decidim_amendable_type],
              # unique: true,
              name: "index_on_amender_and_amendable"

    add_index :decidim_amendments,
              [:decidim_amendable_id, :decidim_amendable_type],
              # unique: true,
              name: "index_on_amendable"

  end
end
