# frozen_string_literal: true

class AddVerifiableResultsToDecidimElectionsElection < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_elections_elections, :verifiable_results_file_url, :string
    add_column :decidim_elections_elections, :verifiable_results_file_hash, :string
  end
end
