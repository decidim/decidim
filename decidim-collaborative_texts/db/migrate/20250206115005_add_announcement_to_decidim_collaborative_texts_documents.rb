# frozen_string_literal: true

class AddAnnouncementToDecidimCollaborativeTextsDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_collaborative_texts_documents, :announcement, :jsonb
  end
end
