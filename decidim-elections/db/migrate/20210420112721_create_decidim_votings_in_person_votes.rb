# frozen_string_literal: true

class CreateDecidimVotingsInPersonVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_votings_in_person_votes do |t|
      t.belongs_to :decidim_elections_election, null: false, index: false
      t.belongs_to :decidim_votings_polling_station, null: true, index: false
      t.belongs_to :decidim_votings_polling_officer, null: true, index: false
      t.string :message_id, null: false
      t.string :voter_id, null: false
      t.integer :status, null: false

      t.timestamps

      t.index [:decidim_elections_election_id, :decidim_votings_polling_station_id],
              name: "decidim_votings_in_person_votes_polling_station_id"
      t.index [:decidim_elections_election_id, :voter_id],
              name: "decidim_votings_in_person_votes_voter_id"
    end
  end
end
