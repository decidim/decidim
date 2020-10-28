# frozen_string_literal: true

class CreateDecidimElectionsElectionsTrustees < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_elections_trustees do |t|
      t.belongs_to :decidim_elections_election, null: false, index: { name: "index_elections_trustees_on_decidim_elections_election_id" }
      t.belongs_to :decidim_elections_trustee, null: false, index: { name: "index_elections_trustees_on_decidim_elections_trustee_id" }
    end
  end
end
