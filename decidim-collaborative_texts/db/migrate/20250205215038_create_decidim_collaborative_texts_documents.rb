# frozen_string_literal: true

class CreateDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_collaborative_texts_documents do |t|
      t.integer :decidim_component_id
      t.string :title
      t.timestamp :published_at, index: true
      t.boolean :accepting_suggestions

      t.timestamps
    end
  end
end
