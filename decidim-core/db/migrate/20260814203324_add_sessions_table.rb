# frozen_string_literal: true

class AddSessionsTable < ActiveRecord::Migration[8.1]
  # Marks a `sessions` table created by this migration. Rollback only drops tables
  # carrying this marker, so a table that already existed before the migration (for
  # example one created by activerecord-session_store) and its stored sessions are
  # never lost.
  CREATED_MARKER = "decidim:add_sessions_table"

  # Columns the session store relies on, with the types each one accepts. The data column
  # also supports the JSON types, which the `:json` serializer writes into. The primary key
  # also accepts UUID columns, which the session store can use without changes as long as the
  # database generates the values through a default (see `uuid_default_problem`).
  REQUIRED_COLUMNS = {
    "id" => [:integer, :uuid],
    "session_id" => [:string],
    "data" => [:text, :json, :jsonb],
    "created_at" => [:datetime],
    "updated_at" => [:datetime]
  }.freeze

  # With `secure_session_only` the store writes the private session ID, which is
  # "2::" followed by the SHA256 hexdigest of the public ID: 67 characters. A string
  # column shorter than this cannot hold the value.
  MIN_SESSION_ID_LENGTH = 67

  def up
    if table_exists?(:sessions)
      ensure_compatible_sessions_table!

      ensure_unique_session_id_index!
      add_index :sessions, :updated_at, if_not_exists: true
    else
      # This statement is imported from
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

  # Presence alone is not enough: the session store reads `session_id` as a string and
  # updates records through a numeric `id` primary key, so an existing table with the same
  # column names but a different schema (or a non-numeric primary key) is rejected as well.
  def ensure_compatible_sessions_table!
    problems = schema_problems(connection.columns(:sessions).index_by(&:name))
    return if problems.empty?

    raise "The existing `sessions` table is not compatible with the session store schema. " \
          "#{problems.join(". ")} Rename or remove the table before running this migration."
  end

  def schema_problems(columns)
    missing = []
    incompatible = []
    REQUIRED_COLUMNS.each do |name, types|
      column = columns[name]
      if column.nil?
        missing << name
      elsif types.exclude?(column.type)
        incompatible << "#{name} (expected #{types.join(" or ")}, found #{column.type})"
      end
    end
    incompatible << "id is not the table primary key" unless connection.primary_key(:sessions) == "id"
    incompatible.concat([uuid_default_problem(columns["id"]), session_id_length_problem(columns["session_id"])].compact)

    [
      ("Missing column(s): #{missing.join(", ")}" unless missing.empty?),
      ("Incompatible column(s): #{incompatible.join(", ")}" unless incompatible.empty?)
    ].compact
  end

  def session_id_length_problem(column)
    return if column.nil? || column.limit.nil? || column.limit >= MIN_SESSION_ID_LENGTH

    "session_id (limit #{column.limit} cannot hold the #{MIN_SESSION_ID_LENGTH}-character private session IDs; widen the column before running this migration)"
  end

  # A UUID key has no sequence behind it, so the session store can only insert rows when the
  # database generates the value through a default such as `gen_random_uuid()`. Integer keys
  # are unaffected because their sequence supplies the value.
  def uuid_default_problem(column)
    return if column.nil? || column.type != :uuid || column.default_function.present?

    "id (uuid primary key without a generated default cannot be populated by the session store; add a default such as gen_random_uuid() before running this migration)"
  end

  # `if_not_exists` is name-based and would silently preserve a pre-existing non-unique
  # index on `session_id`, which the session store cannot rely on. Verify every index on
  # the column, keep an existing unconditional unique one, replace the non-unique matches
  # when uniqueness can be enforced, otherwise stop with an actionable error. A partial
  # unique index (with a WHERE predicate) does not enforce uniqueness outside its
  # predicate, so it does not satisfy the requirement on its own.
  def ensure_unique_session_id_index!
    indexes = session_id_indexes
    return add_index :sessions, :session_id, unique: true if indexes.empty?

    non_unique = indexes.reject(&:unique)
    return remove_session_id_indexes(non_unique) if indexes.any? { |index| index.unique && index.where.nil? }

    ensure_no_duplicate_session_ids!
    remove_session_id_indexes(non_unique)
    add_index :sessions, :session_id, unique: true, name: unique_session_id_index_name(session_id_indexes)
  end

  def session_id_indexes
    connection.indexes(:sessions).select { |existing| existing.columns == ["session_id"] }
  end

  def remove_session_id_indexes(indexes)
    indexes.each { |index| remove_index :sessions, name: index.name }
  end

  def ensure_no_duplicate_session_ids!
    duplicate_session_id = connection.select_value("SELECT session_id FROM sessions GROUP BY session_id HAVING COUNT(*) > 1 LIMIT 1")
    return unless duplicate_session_id

    raise "The existing `sessions` table has no unconditional unique index on `session_id` and duplicate session_id values " \
          "(e.g. #{duplicate_session_id}). The required unique index cannot be created. Remove the duplicate " \
          "sessions or make the index unique before running this migration."
  end

  # Avoid a name clash with the default name already used by a partial unique index.
  def unique_session_id_index_name(indexes)
    indexes.map(&:name).include?("index_sessions_on_session_id") ? "index_sessions_on_session_id_unconditional" : "index_sessions_on_session_id"
  end
end
