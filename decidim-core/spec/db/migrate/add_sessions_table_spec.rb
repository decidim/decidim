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

  def create_sessions_table!(columns, primary_key: :integer)
    connection.create_table :sessions, id: primary_key do |t|
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

    context "when id is not a numeric primary key" do
      before { create_sessions_table!(default_columns, primary_key: :string) }

      it "raises naming the incompatible primary key" do
        expect { migration.up }.to raise_error(/Incompatible column\(s\): id \(expected integer, found string\)/)
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
