# frozen_string_literal: true

class AddSessionsTable < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:sessions)
      # An existing `sessions` table (for example one created by activerecord-session_store)
      # is reused as-is so stored sessions are preserved; only the missing indexes are added.
      ensure_compatible_sessions_table!

      add_index :sessions, :session_id, unique: true unless index_exists?(:sessions, :session_id)
      add_index :sessions, :updated_at unless index_exists?(:sessions, :updated_at)
    else
      create_table :sessions do |t|
        t.string :session_id, null: false
        t.text :data
        t.timestamps
      end

      add_index :sessions, :session_id, unique: true
      add_index :sessions, :updated_at
    end
  end

  private

  def ensure_compatible_sessions_table!
    missing_columns = %w(session_id data created_at updated_at).reject { |column| column_exists?(:sessions, column) }
    return if missing_columns.empty?

    raise "The existing `sessions` table is not compatible with the session store schema. " \
          "Missing column(s): #{missing_columns.join(", ")}. Rename or remove the table before running this migration."
  end
end
