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

  def session_id_indexes
    connection.indexes(:sessions).select { |existing| existing.columns == ["session_id"] }
  end

  describe "#migrate :up" do
    it "creates the table with the columns the session store uses" do
      migration.migrate(:up)

      columns = connection.columns(:sessions).index_by(&:name)
      expect(columns.transform_values(&:type)).to eq(
        "id" => :integer,
        "session_id" => :string,
        "data" => :text,
        "created_at" => :datetime,
        "updated_at" => :datetime
      )
      expect(columns["session_id"].null).to be(false)
    end

    it "adds the unique index on session_id and the index on updated_at" do
      migration.migrate(:up)

      expect(session_id_indexes.map(&:unique)).to eq([true])
      expect(connection.indexes(:sessions).map(&:columns)).to include(["updated_at"])
    end

    context "when the sessions table already exists" do
      before do
        connection.create_table :sessions do |t|
          t.string :session_id, null: false
          t.text :data
          t.timestamps
        end
      end

      it "fails instead of adopting the existing table, which has to be handled by the application" do
        expect { migration.migrate(:up) }.to raise_error(ActiveRecord::StatementInvalid, /already exists/)
      end
    end
  end

  describe "#migrate :down" do
    before { migration.migrate(:up) }

    it "drops the table created by the migration" do
      migration.migrate(:down)

      expect(connection.table_exists?(:sessions)).to be(false)
    end
  end
end
