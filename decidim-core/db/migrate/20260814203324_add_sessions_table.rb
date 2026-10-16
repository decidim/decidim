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

      ensure_unique_session_id_index!
      add_index :sessions, :updated_at, if_not_exists: true
    else
      # this create_table statement is imported from
      # https://github.com/rails/activerecord-session_store/blob/main/lib/generators/active_record/templates/migration.rb
      # and must be kept as close as possible to the one provided by the activerecord-session_store.
      # We had to massive modify this file, just to make sure other people is not already using the gem independently.
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

  # `if_not_exists` is name-based and would silently preserve a pre-existing non-unique
  # index on `session_id`, which the session store cannot rely on. Verify the index and
  # replace it when uniqueness can be enforced, otherwise stop with an actionable error.
  def ensure_unique_session_id_index!
    index = connection.indexes(:sessions).find { |existing| existing.columns == ["session_id"] }
    return add_index :sessions, :session_id, unique: true if index.nil?
    return if index.unique

    duplicate_session_id = connection.select_value("SELECT session_id FROM sessions GROUP BY session_id HAVING COUNT(*) > 1 LIMIT 1")
    if duplicate_session_id
      raise "The existing `sessions` table has a non-unique index on `session_id` and duplicate session_id values " \
            "(e.g. #{duplicate_session_id}). The required unique index cannot be created. Remove the duplicate " \
            "sessions or make the index unique before running this migration."
    end

    remove_index :sessions, name: index.name
    add_index :sessions, :session_id, unique: true
  end
end
