# frozen_string_literal: true

class CreateDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_collaborative_texts_documents do |t|
      t.integer :decidim_component_id
      t.string :title
      t.jsonb :announcement
      t.boolean :accepting_suggestions, null: false, default: false
      t.timestamp :published_at, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
