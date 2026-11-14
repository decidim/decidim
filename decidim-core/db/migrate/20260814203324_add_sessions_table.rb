# frozen_string_literal: true

# This migration is coming from the activerecord-session_store . We are not going to change it.
class AddSessionsTable < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id, :unique => true
    add_index :sessions, :updated_at
  end
end
