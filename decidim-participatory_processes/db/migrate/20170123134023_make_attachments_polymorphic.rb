# frozen_string_literal: true

class MakeAttachmentsPolymorphic < ActiveRecord::Migration[5.0]
  def change
    transaction do
      remove_index :decidim_participatory_process_attachments, name: "index_decidim_processes_attachments_on_decidim_process_id"
      rename_table :decidim_participatory_process_attachments, :decidim_attachments

      add_column :decidim_attachments, :attachable_type, :string
      execute("UPDATE decidim_attachments SET attachable_type = 'Decidim::ParticipatoryProcess'")

      rename_column :decidim_attachments, :decidim_participatory_process_id, :attachable_id
      add_index :decidim_attachments, [:attachable_id, :attachable_type]

      change_column_null(:decidim_attachments, :attachable_id, false)
      change_column_null(:decidim_attachments, :attachable_type, false)
    end
  end
end
