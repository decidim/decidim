# frozen_string_literal: true

class IndexForeignKeysInDecidimAttachments < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_attachments, :attachment_collection_id
  end
end
