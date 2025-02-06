# frozen_string_literal: true

class AddDeletedAtToDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_collaborative_texts_documents, :deleted_at, :datetime
    add_index :decidim_collaborative_texts_documents, :deleted_at
  end
end
