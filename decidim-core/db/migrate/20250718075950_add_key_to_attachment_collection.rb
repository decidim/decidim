# frozen_string_literal: true

class AddKeyToAttachmentCollection < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_attachment_collections, :key, :string
    add_index :decidim_attachment_collections, :key
  end
end
