# frozen_string_literal: true

class CreateCollaborativeTextsVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_collaborative_texts_versions do |t|
      t.references :document, null: false, index: true
      t.string :body
      t.timestamps
    end
  end
end
