# frozen_string_literal: true

class AddReferenceToDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[8.0]
  class Document < ApplicationRecord
    self.table_name = :decidim_collaborative_texts_documents

    include Decidim::HasComponent
    include Decidim::HasReference
  end

  def change
    add_column :decidim_collaborative_texts_documents, :reference, :string
    Document.reset_column_information
    Document.find_each { |document| document.send(:store_reference) }
  end
end
