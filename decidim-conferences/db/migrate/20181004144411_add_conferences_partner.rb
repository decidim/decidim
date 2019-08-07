# frozen_string_literal: true

class AddConferencesPartner < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conferences_partners do |t|
      t.references :decidim_conference, index: true
      t.string :name, null: false
      t.string :partner_type, null: false
      t.integer :weight, null: false, default: 0
      t.string :link
      t.string :logo, null: false

      t.timestamps
    end

    add_index :decidim_conferences_partners, [:weight, :partner_type]
  end
end
