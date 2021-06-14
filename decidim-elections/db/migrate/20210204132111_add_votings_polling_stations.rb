# frozen_string_literal: true

class AddVotingsPollingStations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_polling_stations do |t|
      t.jsonb :title, null: false
      t.text :address
      t.float :latitude
      t.float :longitude
      t.jsonb :location
      t.jsonb :location_hints
      t.references :decidim_votings_voting,
                   null: false,
                   index: { name: "decidim_votings_votings_polling_stations" }

      t.timestamps
    end
  end
end
