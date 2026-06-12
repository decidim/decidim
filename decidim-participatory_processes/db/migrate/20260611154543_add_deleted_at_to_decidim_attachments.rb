class AddDeletedAtToDecidimAttachments < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_attachments, :deleted_at, :datetime
    add_index :decidim_attachments, :deleted_at
  end
end
