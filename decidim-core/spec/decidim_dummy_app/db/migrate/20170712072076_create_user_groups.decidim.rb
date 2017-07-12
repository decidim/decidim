# This migration comes from decidim (originally 20170119145359)
# frozen_string_literal: true

class CreateUserGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_user_groups do |t|
      t.string :name, null: false
      t.string :document_number, null: false
      t.string :phone, null: false

      t.timestamps
    end
  end
end
