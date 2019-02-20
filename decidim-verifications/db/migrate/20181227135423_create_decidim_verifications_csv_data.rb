# frozen_string_literal: true

class CreateDecidimVerificationsCsvData < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_verifications_csv_data do |t|
      t.string :email
      t.references :decidim_organization, foreign_key: true, index: { name: "index_verifications_csv_census_to_organization" }

      t.timestamps
    end
  end
end
