# frozen_string_literal: true

class AddAllowCensusCheckBeforeStartToDecidimElectionsElections < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_elections_elections, :allow_census_check_before_start, :boolean, default: false, null: false
  end
end
