# frozen_string_literal: true

class AddReferenceToDecidimElectionsElections < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_elections_elections, :reference, :string
  end
end
