# frozen_string_literal: true

class CreateDecidimUserSuspensions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_user_suspensions do |t|
      t.belongs_to :decidim_user, foreign_key: true
      t.integer :suspending_user_id
      t.text :justification

      t.timestamps
    end
    add_foreign_key :decidim_user_suspensions, :decidim_users, column: :suspending_user_id
  end
end
