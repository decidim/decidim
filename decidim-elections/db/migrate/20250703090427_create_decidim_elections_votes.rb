# frozen_string_literal: true

class CreateDecidimElectionsVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_elections_votes do |t|
      t.references :question, null: false, foreign_key: { to_table: :decidim_elections_questions }, index: true
      t.references :response_option, null: false, foreign_key: { to_table: :decidim_elections_response_options }, index: true
      t.string :voter_uid, null: false, index: true

      t.timestamps
    end

    add_column :decidim_elections_response_options, :votes_count, :integer, default: 0, null: false
    add_column :decidim_elections_questions, :votes_count, :integer, default: 0, null: false
    add_column :decidim_elections_elections, :votes_count, :integer, default: 0, null: false
  end
end
