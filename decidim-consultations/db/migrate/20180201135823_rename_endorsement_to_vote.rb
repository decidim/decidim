# frozen_string_literal: true

class RenameEndorsementToVote < ActiveRecord::Migration[5.1]
  def change
    rename_table :decidim_consultations_endorsements, :decidim_consultations_votes
    rename_column :decidim_consultations_questions, :endorsements_count, :votes_count
    rename_column :decidim_consultations, :start_endorsing_date, :start_voting_date
    rename_column :decidim_consultations, :end_endorsing_date, :end_voting_date
    rename_column :decidim_consultations_questions, :external_endorsement, :external_voting

    rename_index :decidim_consultations_votes,
                 :index_consultations_endorsements_on_author,
                 :index_consultations_votes_on_author

    rename_index :decidim_consultations_votes,
                 :index_consultations_endorsements_on_consultation_question,
                 :index_consultations_votes_on_consultation_question

    rename_index :decidim_consultations_votes,
                 :index_consultations_endorsements_on_consultations_response_id,
                 :index_consultations_votes_on_consultations_response_id
  end
end
