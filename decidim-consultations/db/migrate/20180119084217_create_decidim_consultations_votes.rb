# frozen_string_literal: true

class CreateDecidimConsultationsVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_consultations_votes do |t|
      t.references :decidim_consultation_question, index: { name: "index_consultations_votes_on_consultation_question" }
      t.references :decidim_author, index: { name: "index_consultations_votes_on_author" }

      t.timestamps
    end

    add_index :decidim_consultations_votes,
              [:decidim_consultation_question_id, :decidim_author_id],
              unique: true,
              name: "index_question_votes_author_unique"
  end
end
