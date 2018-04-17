# frozen_string_literal: true

class RenameVoteRelatedAttributes < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_consultations, :start_voting_date, :start_endorsing_date
    rename_column :decidim_consultations, :end_voting_date, :end_endorsing_date
    rename_column :decidim_consultations_questions, :external_voting, :external_endorsement
  end
end
