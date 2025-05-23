# frozen_string_literal: true

class AddCensusFieldsToDecidimElectionsElections < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_elections_elections, :internal_census, :boolean, default: false, null: false
    add_column :decidim_elections_elections, :verification_types, :string, array: true, default: []

    add_index :decidim_elections_elections, :internal_census
  end
end
