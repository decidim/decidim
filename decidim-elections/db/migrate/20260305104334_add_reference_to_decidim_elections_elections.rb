# frozen_string_literal: true

class AddReferenceToDecidimElectionsElections < ActiveRecord::Migration[8.0]
  class Election < ApplicationRecord
    self.table_name = :decidim_elections_elections

    include Decidim::HasComponent
    include Decidim::HasReference
  end

  def change
    add_column :decidim_elections_elections, :reference, :string
    Election.reset_column_information
    Election.find_each { |election| election.send(:store_reference) }
  end
end
