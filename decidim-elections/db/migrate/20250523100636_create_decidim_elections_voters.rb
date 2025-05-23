# frozen_string_literal: true

class CreateDecidimElectionsVoters < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_elections_voters do |t|
      t.references :election, null: false, foreign_key: { to_table: :decidim_elections_elections }
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end
