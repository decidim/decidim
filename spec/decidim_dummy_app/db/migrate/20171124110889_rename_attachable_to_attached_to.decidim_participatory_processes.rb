# This migration comes from decidim_participatory_processes (originally 20170125135937)
# frozen_string_literal: true

class RenameAttachableToAttachedTo < ActiveRecord::Migration[5.0]
  def change
    remove_index :decidim_attachments, name: "index_decidim_attachments_on_attachable_id_and_attachable_type"
    remove_foreign_key :decidim_attachments, column: :attachable_id

    rename_column :decidim_attachments, :attachable_id, :attached_to_id
    rename_column :decidim_attachments, :attachable_type, :attached_to_type

    add_index :decidim_attachments, [:attached_to_id, :attached_to_type], name: "index_decidim_attachments_on_attached_to"
  end
end
