# frozen_string_literal: true

class AddAccessCodesToCensusData < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_census_data, :access_code, :string

    add_column :decidim_votings_census_data, :hashed_booth_data, :string
    add_index :decidim_votings_census_data, :hashed_booth_data

    add_column :decidim_votings_census_data, :hashed_personal_data, :string
    add_index :decidim_votings_census_data, :hashed_personal_data

    add_column :decidim_votings_census_data, :hashed_identification_data, :string
    add_index :decidim_votings_census_data, :hashed_identification_data

    remove_column :decidim_votings_census_data, :document_number, :string
    remove_column :decidim_votings_census_data, :document_type, :string
    remove_column :decidim_votings_census_data, :birthdate, :string
  end
end
