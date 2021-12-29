# frozen_string_literal: true

class CreateElectionsResults < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_results do |t|
      t.integer :votes_count, default: 0, null: false

      t.belongs_to :decidim_elections_answer, index: true
      t.belongs_to :decidim_votings_polling_station,
                   null: true,
                   index: { name: "index_decidim_elections_results_on_polling_station_id" }

      t.timestamps
    end
  end
end
