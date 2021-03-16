# frozen_string_literal: true

class AddDecidimVotingsCensusDatasets < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_census_datasets do |t|
      t.string :file
      t.integer :status, null: false

      t.belongs_to :decidim_organization, null: false, index: { name: "decidim_organization_voting_census_dataset" }
      t.belongs_to :decidim_votings_voting, null: false, index: { name: "decidim_votings_voting_census_dataset" }

      t.timestamps
    end
  end
end
