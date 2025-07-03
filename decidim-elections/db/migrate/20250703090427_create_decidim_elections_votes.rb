# frozen_string_literal: true

class CreateDecidimElectionsVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_elections_votes do |t|
      t.references :decidim_elections_voter, null: false, foreign_key: true
      t.references :decidim_elections_question, null: false, foreign_key: true
      t.references :decidim_elections_response_option, null: false, foreign_key: true

      t.timestamps

      t.index [:decidim_elections_voter_id, :decidim_elections_question_id, :decidim_elections_response_option_id],
              unique: true,
              name: "index_votes_on_voter_question_option"
    end

    add_column :decidim_elections_response_options, :votes_count, :integer, default: 0, null: false
  end
end
