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

  describe "#up" do
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
  end
end
