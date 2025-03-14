# frozen_string_literal: true

class CreatePrivateExports < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_private_exports, id: :uuid do |t|
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
  end
end
