# frozen_string_literal: true

class CreateDecidimElectionsVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_votes do |t|
      t.belongs_to :decidim_elections_election, null: false, index: { name: "index_elections_votes_on_decidim_elections_election_id" }
      t.string :voter_id, null: false
      t.string :encrypted_vote_hash, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
