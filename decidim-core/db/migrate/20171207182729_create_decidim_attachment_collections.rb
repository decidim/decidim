# frozen_string_literal: true

class CreateDecidimAttachmentCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_attachment_collections do |t|
      t.jsonb :name, null: false
      t.jsonb :description, null: false
      t.references :decidim_participatory_space, polymorphic: true, null: false, index: { name: "decidim_attachment_collections_participatory_space_id_and_type" }
    end
  end
end
