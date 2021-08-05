# frozen_string_literal: true

class CreateDecidimContentBlockAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_content_block_attachments do |t|
      t.string :name
      t.references :decidim_content_block, null: false, index: { name: "decidim_content_block_attachments_on_content_block" }
    end
  end
end
