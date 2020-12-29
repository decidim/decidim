# frozen_string_literal: true

class CreateDecidimVerificationsConflicts < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_verifications_conflicts do |t|
      t.references :current_user, index: { name: "authorization_current_user" }, foreign_key: { to_table: :decidim_users }
      t.references :managed_user, index: { name: "authorization_managed_user" }, foreign_key: { to_table: :decidim_users }
      t.integer :times, default: 0
      t.string :unique_id
      t.boolean :solved, default: false

      t.timestamps
    end
  end
end
