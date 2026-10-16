# frozen_string_literal: true

class AddSessionsTable < ActiveRecord::Migration[8.1]
  # Marks a `sessions` table created by this migration. Rollback only drops tables
  # carrying this marker, so a table that already existed before the migration (for
  # example one created by activerecord-session_store) and its stored sessions are
  # never lost.
  CREATED_MARKER = "decidim:add_sessions_table"

  def up
    if table_exists?(:sessions)
      ensure_compatible_sessions_table!

      add_index :sessions, :session_id, unique: true, if_not_exists: true
      add_index :sessions, :updated_at, if_not_exists: true
    else
      create_table :sessions, comment: CREATED_MARKER do |t|
        t.string :session_id, null: false
        t.text :data
        t.timestamps
      end

      add_index :sessions, :session_id, unique: true
      add_index :sessions, :updated_at
    end
  end

  def down
    return unless table_exists?(:sessions)
    return unless connection.table_comment("sessions") == CREATED_MARKER

    drop_table :sessions
  end

  private

  def ensure_compatible_sessions_table!
    missing_columns = %w(session_id data created_at updated_at).reject { |column| column_exists?(:sessions, column) }
    return if missing_columns.empty?

    raise "The existing `sessions` table is not compatible with the session store schema. " \
          "Missing column(s): #{missing_columns.join(", ")}. Rename or remove the table before running this migration."
  end
end
