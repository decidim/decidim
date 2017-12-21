# frozen_string_literal: true

class CreateDecidimAttachmentCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_attachment_collections do |t|
      t.jsonb :name, null: false
      t.jsonb :description, null: false
      t.integer :weight, null: false, default: 0
      t.references :collection_for, polymorphic: true, null: false, index: { name: "decidim_attachment_collections_collection_for_id_and_type" }
    end
  end
end
