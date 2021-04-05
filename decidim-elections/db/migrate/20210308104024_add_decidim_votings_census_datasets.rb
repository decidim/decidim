# frozen_string_literal: true

class AddDecidimVotingsCensusDatasets < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_census_datasets do |t|
      t.string :file
      t.integer :status, null: false
      t.integer :data_count
      t.integer :csv_row_raw_count, null: false
      t.integer :csv_row_processed_count, default: 0

      t.belongs_to :decidim_votings_voting, null: false, index: { name: "decidim_votings_voting_census_dataset" }

      t.timestamps
    end
  end
end
