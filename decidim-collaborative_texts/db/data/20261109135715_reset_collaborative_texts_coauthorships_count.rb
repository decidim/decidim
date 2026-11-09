# frozen_string_literal: true

class ResetCollaborativeTextsCoauthorshipsCount < ActiveRecord::Migration[7.2]
  class Document < ApplicationRecord
    self.table_name = :decidim_collaborative_texts_documents

    has_many :coauthorships,
             -> { order(:created_at) },
             as: :coauthorable,
             class_name: "Decidim::Coauthorship"

    def self.polymorphic_name
      "Decidim::CollaborativeTexts::Document"
    end
  end

  def up
    Document.reset_column_information
    Document.find_each do |document|
      Document.reset_counters(document.id, :coauthorships)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
