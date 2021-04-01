# frozen_string_literal: true

class AddCensusContactInformationToVotings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votings, :census_contact_information, :string
  end
end
