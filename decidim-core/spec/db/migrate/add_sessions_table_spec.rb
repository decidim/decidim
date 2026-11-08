# frozen_string_literal: true

require "spec_helper"

describe "AddSessionsTable", type: :migration do
  let(:connection) { ActiveRecord::Base.connection }

  # The dummy app already has the table created by this migration, so every scenario builds
  # its own inside a transaction that is rolled back to restore the original schema.
  around do |example|
    connection.transaction do
      connection.drop_table(:sessions, if_exists: true)
      example.run
      raise ActiveRecord::Rollback
    end
  end

  def default_columns
    {
      "id" => :integer,
      "session_id" => :string,
      "data" => :text,
      "created_at" => :datetime,
      "updated_at" => :datetime
    }
  end

  # `default: :generated` keeps the adapter's own default (the sequence for integer keys,
  # `gen_random_uuid()` for UUID keys); passing an explicit value, including nil, overrides it.
  def create_sessions_table!(columns, primary_key: :integer, default: :generated)
    options = { id: primary_key }
    options[:default] = default unless default == :generated

    connection.create_table :sessions, **options do |t|
      columns.each do |name, type|
        next if name == "id" && primary_key

        t.column name, type
      end
    end
  end

  def session_id_indexes
    connection.indexes(:sessions).select { |existing| existing.columns == ["session_id"] }
  end

  describe "#up" do
    context "when the table does not exist" do
      it "creates the table marked with CREATED_MARKER and the required indexes" do
        migration.up

        expect(connection.table_comment("sessions")).to eq(AddSessionsTable::CREATED_MARKER)
        expect(session_id_indexes.map(&:unique)).to eq([true])
        expect(connection.indexes(:sessions).map(&:columns)).to include(["updated_at"])
      end
    end

    context "when the existing table matches the session store schema" do
      before { create_sessions_table!(default_columns) }

      it "accepts the table" do
        expect { migration.up }.not_to raise_error
      end
    end

    context "when id is a generated bigint primary key" do
      before { create_sessions_table!(default_columns, primary_key: :bigint) }

      it "accepts the table" do
        expect { migration.up }.not_to raise_error
      end
    end

    context "when data is one of the supported JSON types" do
      before { create_sessions_table!(default_columns.merge("data" => :jsonb)) }

      it "accepts the table" do
        expect { migration.up }.not_to raise_error
      end
    end

    context "when a required column is missing" do
      before { create_sessions_table!(default_columns.except("data")) }

      it "raises naming the missing column" do
        expect { migration.up }.to raise_error(/Missing column\(s\): data/)
      end
    end

    context "when session_id is not a string" do
      before { create_sessions_table!(default_columns.merge("session_id" => :integer)) }

      it "raises naming the incompatible column type" do
        expect { migration.up }.to raise_error(/Incompatible column\(s\): session_id \(expected string, found integer\)/)
      end
    end

    context "when id is not a numeric or UUID primary key" do
      before { create_sessions_table!(default_columns, primary_key: :string) }

      it "raises naming the incompatible primary key" do
        expect { migration.up }.to raise_error(/Incompatible column\(s\): id \(expected integer or uuid, found string\)/)
      end
    end

    context "when id is a UUID primary key" do
      before { create_sessions_table!(default_columns, primary_key: :uuid) }

      it "accepts the table" do
        expect { migration.up }.not_to raise_error
      end
    end

    context "when id is a UUID primary key without a generated default" do
      before { create_sessions_table!(default_columns, primary_key: :uuid, default: nil) }

      it "raises naming the missing generated default" do
        expect { migration.up }.to raise_error(
          /Incompatible column\(s\): id \(uuid primary key without a generated default cannot be populated by the session store/
        )
      end
    end

    context "when id is an integer primary key without a generated default" do
      before { create_sessions_table!(default_columns, primary_key: :integer, default: nil) }

      it "raises naming the missing generated default" do
        expect { migration.up }.to raise_error(
          /Incompatible column\(s\): id \(integer primary key without a generated default cannot be populated by the session store/
        )
      end
    end

    # Identity columns have no default function but are populated by the database, so they are
    # accepted even though the check above looks for a generated default.
    context "when id is an integer primary key created as identity" do
      before do
        connection.execute(
          "CREATE TABLE sessions (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, session_id varchar, data text, created_at timestamp, updated_at timestamp)"
        )
      end

      it "accepts the table" do
        expect { migration.up }.not_to raise_error
      end
    end

    context "when session_id is limited to less than the private session ID length" do
      before do
        create_sessions_table!(default_columns)
        connection.change_column :sessions, :session_id, :string, limit: 32
      end

      it "raises naming the too short column" do
        expect { migration.up }.to raise_error(/Incompatible column\(s\): session_id \(limit 32 cannot hold the 67-character private session IDs/)
      end
    end

    context "when id is present but is not the primary key" do
      before { create_sessions_table!(default_columns, primary_key: false) }

      it "raises naming the primary key configuration" do
        expect { migration.up }.to raise_error(/id is not the table primary key/)
      end
    end

    context "when no index on session_id exists" do
      before { create_sessions_table!(default_columns) }

      it "adds a unique index on session_id" do
        migration.up

        expect(session_id_indexes.map(&:unique)).to eq([true])
      end
    end

    context "when a non-unique index on session_id exists" do
      before do
        create_sessions_table!(default_columns)
        connection.add_index :sessions, :session_id
      end

      it "replaces it with a unique index" do
        migration.up

        expect(session_id_indexes.map(&:unique)).to eq([true])
      end
    end

    context "when multiple indexes on session_id exist and one is unique" do
      before do
        create_sessions_table!(default_columns)
        connection.add_index :sessions, :session_id, name: "sessions_session_id_non_unique"
        connection.add_index :sessions, :session_id, name: "sessions_session_id_unique", unique: true
      end

      it "keeps the unique index and removes the non-unique matches" do
        migration.up

        expect(session_id_indexes.map(&:name)).to eq(["sessions_session_id_unique"])
      end
    end

    context "when only a partial unique index on session_id exists" do
      before do
        create_sessions_table!(default_columns)
        connection.add_index :sessions, :session_id, name: "sessions_session_id_partial_unique", unique: true, where: "data IS NOT NULL"
      end

      it "keeps the partial index and adds an unconditional unique one" do
        migration.up

        partial = session_id_indexes.find { |index| index.name == "sessions_session_id_partial_unique" }
        expect(partial.where).to eq("(data IS NOT NULL)")
        expect(session_id_indexes.reject(&:where).map(&:unique)).to eq([true])
      end
    end

    context "when a partial unique index and a full non-unique index on session_id exist" do
      before do
        create_sessions_table!(default_columns)
        connection.add_index :sessions, :session_id, name: "sessions_session_id_partial_unique", unique: true, where: "data IS NOT NULL"
        connection.add_index :sessions, :session_id, name: "sessions_session_id_non_unique"
      end

      it "removes the non-unique index and adds an unconditional unique one" do
        migration.up

        names = session_id_indexes.map(&:name)
        expect(names).to include("sessions_session_id_partial_unique")
        expect(names).not_to include("sessions_session_id_non_unique")
        expect(session_id_indexes.reject(&:where).map(&:unique)).to eq([true])
      end
    end

    context "when only non-unique indexes on session_id exist and data has duplicates" do
      before do
        create_sessions_table!(default_columns)
        connection.add_index :sessions, :session_id, name: "sessions_session_id_first"
        connection.add_index :sessions, :session_id, name: "sessions_session_id_second"
        connection.execute("INSERT INTO sessions (session_id, data) VALUES ('duplicate', '')")
        connection.execute("INSERT INTO sessions (session_id, data) VALUES ('duplicate', '')")
      end

      it "raises naming the duplicate session_id values" do
        expect { migration.up }.to raise_error(/duplicate session_id values/)
      end
    end
  end

  describe "#down" do
    context "when the table does not exist" do
      it "does nothing" do
        expect { migration.down }.not_to raise_error

        expect(connection.table_exists?(:sessions)).to be(false)
      end
    end

    context "when the table was created by this migration (carries the marker)" do
      before { migration.up }

      it "drops the table" do
        migration.down

        expect(connection.table_exists?(:sessions)).to be(false)
      end
    end

    context "when the table exists without the marker (created outside this migration)" do
      before do
        create_sessions_table!(default_columns)
        connection.execute("INSERT INTO sessions (session_id, data) VALUES ('existing-session', 'data')")
      end

      it "keeps the table and its stored sessions" do
        migration.up
        migration.down

        expect(connection.table_exists?(:sessions)).to be(true)
        expect(connection.select_value("SELECT COUNT(*) FROM sessions WHERE session_id = 'existing-session'")).to eq(1)
      end
    end
  end
end
