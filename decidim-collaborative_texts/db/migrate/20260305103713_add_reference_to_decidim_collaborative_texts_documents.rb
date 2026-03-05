# frozen_string_literal: true

class AddReferenceToDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_collaborative_texts_documents, :reference, :string
  end
end
