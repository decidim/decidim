# frozen_string_literal: true

class CreateDecidimUserReports < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_user_reports do |t|
      t.integer :reporter_id, foreign_key: true
      t.integer :reported_id, foreign_key: true
      t.string :reason
      t.text :details

      t.timestamps
    end
    add_foreign_key :decidim_user_reports, :decidim_users, column: :reported_id
    add_foreign_key :decidim_user_reports, :decidim_users, column: :reporter_id
  end
end
