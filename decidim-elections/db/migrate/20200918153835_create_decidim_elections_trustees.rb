# frozen_string_literal: true

class CreateDecidimElectionsTrustees < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_trustees do |t|
      t.references :decidim_user, null: false, index: true
      t.string :public_key

      t.timestamps
    end
  end
end
