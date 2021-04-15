# frozen_string_literal: true

class CreateElectionsClosures < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_closures do |t|
      t.string :polling_officer_notes, null: true

      t.belongs_to :decidim_elections_election,
                   null: false,
                   index: { name: "index_decidim_elections_closures_on_election_id" }
      t.belongs_to :decidim_votings_polling_station,
                   null: true,
                   index: { name: "index_decidim_elections_closures_on_polling_station_id" }
      t.belongs_to :decidim_votings_polling_officer,
                   null: false,
                   index: { name: "index_decidim_elections_closures_on_polling_officer_id" }

      t.timestamps
    end
  end
end
