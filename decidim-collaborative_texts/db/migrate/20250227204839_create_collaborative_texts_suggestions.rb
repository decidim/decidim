# frozen_string_literal: true

class CreateCollaborativeTextsSuggestions < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_collaborative_texts_suggestions do |t|
      t.references :document_version, null: false, index: { name: "index_collaborative_texts_suggestions_on_version_id" }
      t.references :decidim_author, polymorphic: true, index: { name: "index_collaborative_texts_suggestions_on_author" }
      t.jsonb :changeset, null: false, default: {}
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
