# frozen_string_literal: true

# This migration comes from decidim (originally 20250819110800)
class ConvertPrivateExportsIdToUuid < ActiveRecord::Migration[7.0]
  def up
    create_table :decidim_private_exports_new, force: :cascade do |t|
      t.uuid :uuid, null: false
      t.string :export_type, null: false
      t.string :attached_to_type
      t.integer :attached_to_id
      t.string :file
      t.string :content_type, null: false
      t.string :file_size, null: false
      t.datetime :expires_at
      t.jsonb :metadata, default: {}
      t.timestamps

      t.index [:uuid], name: "index_decidim_private_exports_on_uuid", unique: true
    end
    # Copy data from old table to new table
    execute <<-SQL.squish
      INSERT INTO decidim_private_exports_new (uuid, export_type, attached_to_type, attached_to_id, file, content_type, file_size, expires_at, metadata, created_at, updated_at)
      SELECT id, export_type, attached_to_type, attached_to_id, file, content_type, file_size, NOW(), metadata, created_at, updated_at
      FROM decidim_private_exports
    SQL

    # Drop old table and rename new table
    drop_table :decidim_private_exports
    rename_table :decidim_private_exports_new, :decidim_private_exports
  end

  def down
    # Similar approach for rollback
    create_table :decidim_private_exports_new, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :export_type, null: false
      t.string :attached_to_type
      t.integer :attached_to_id
      t.string :file
      t.string :content_type, null: false
      t.string :file_size, null: false
      t.datetime :expires_at
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    execute <<-SQL.squish
      INSERT INTO decidim_private_exports_new (id, export_type, attached_to_type, attached_to_id, file, content_type, file_size, expires_at, metadata, created_at, updated_at)
      SELECT uuid, export_type, attached_to_type, attached_to_id, file, content_type, file_size, expires_at, metadata, created_at, updated_at
      FROM decidim_private_exports
    SQL

    drop_table :decidim_private_exports
    rename_table :decidim_private_exports_new, :decidim_private_exports
  end
end
