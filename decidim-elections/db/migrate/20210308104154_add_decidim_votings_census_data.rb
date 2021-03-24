# frozen_string_literal: true

class AddDecidimVotingsCensusData < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_census_data do |t|
      t.string :hashed_in_person_data, index: true
      t.string :hashed_check_data, index: true
      t.string :hashed_online_data, index: true

      t.string :full_name
      t.string :full_address
      t.string :postal_code
      t.string :mobile_phone_number, null: true
      t.string :email, null: true

      t.string :access_code, null: true

      t.belongs_to :decidim_votings_census_dataset, null: false, index: { name: "decidim_votings_census_dataset_census_datum" }

      t.timestamps
    end
  end
end
