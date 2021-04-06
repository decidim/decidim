# frozen_string_literal: true

class AddVotingBallotStyle < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_ballot_styles do |t|
      t.string :code
      t.references :decidim_votings_voting, null: false, index: false

      t.timestamps

      t.index [:decidim_votings_voting_id, :code], name: "decidim_votings_ballot_styles_on_voting_and_code", unique: true
    end

    create_join_table :decidim_votings_ballot_styles, :decidim_elections_questions, table_name: "decidim_votings_ballot_style_questions" do |t|
      t.index :decidim_votings_ballot_style_id, name: "decidim_votings_ballot_styles_questions_ballot_style_id"
      t.index :decidim_elections_question_id, name: "decidim_votings_ballot_styles_questions_question_id"
    end
  end
end
