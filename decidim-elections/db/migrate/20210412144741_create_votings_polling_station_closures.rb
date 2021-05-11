# frozen_string_literal: true

class CreateVotingsPollingStationClosures < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_polling_station_closures do |t|
      t.integer :phase, index: true
      t.string :polling_officer_notes, null: true

      t.belongs_to :decidim_elections_election,
                   null: false,
                   index: false
      t.belongs_to :decidim_votings_polling_station,
                   null: true,
                   index: false
      t.belongs_to :decidim_votings_polling_officer,
                   null: true,
                   index: false

      t.timestamps
    end
  end
end
