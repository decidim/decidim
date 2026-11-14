# frozen_string_literal: true

class AddUniqueKeyToAttachmentCollection < ActiveRecord::Migration[8.1]
  def up
    add_index :decidim_attachment_collections,
              [:collection_for_type, :collection_for_id, :key],
              unique: true,
              name: "index_attachment_collections_unique_key_per_parent"
  end

  def down
    remove_index :decidim_attachment_collections, name: "index_attachment_collections_unique_key_per_parent"
  end
end
