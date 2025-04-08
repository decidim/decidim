# frozen_string_literal: true

class AddCounterCachesToCollaborativeTextsDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_collaborative_texts_documents, :coauthorships_count, :integer, null: false, default: 0
    add_column :decidim_collaborative_texts_documents, :suggestions_count, :integer, null: false, default: 0
    add_column :decidim_collaborative_texts_documents, :document_versions_count, :integer, null: false, default: 0

    add_index :decidim_collaborative_texts_documents, :coauthorships_count, name: "idx_decidim_collaborative_texts_documents_coauthorships_count"
    add_index :decidim_collaborative_texts_documents, :suggestions_count, name: "idx_decidim_collaborative_texts_documents_suggestions_count"
    add_index :decidim_collaborative_texts_documents, :document_versions_count, name: "idx_decidim_collaborative_texts_documents_versions_count"
  end
end
