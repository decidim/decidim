# frozen_string_literal: true

class CreateDecidimElectionsVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_elections_votes do |t|
      t.references :decidim_elections_voter, foreign_key: true
      t.references :decidim_user, foreign_key: { to_table: :decidim_users }
      t.references :decidim_elections_question, null: false, foreign_key: true
      t.references :decidim_elections_response_option, null: false, foreign_key: true
      t.string :voter_uid, null: false

      t.timestamps

      t.index [:voter_uid, :decidim_elections_question_id], unique: true
    end

    add_column :decidim_elections_response_options, :votes_count, :integer, default: 0, null: false
  end
end
