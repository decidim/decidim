# This migration comes from decidim_system (originally 20160919105637)
# frozen_string_literal: true

class DeviseCreateDecidimAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_system_admins do |t|
      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Lockable
      t.integer :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :decidim_system_admins, :email, unique: true
    add_index :decidim_system_admins, :reset_password_token, unique: true
  end
end
