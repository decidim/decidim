# frozen_string_literal: true

class AddPollingOfficersToVotings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_polling_officers do |t|
      t.references :decidim_votings_voting, index: { name: "decidim_votings_votings_polling_officers" }
      t.references :decidim_user, index: true

      t.timestamps
    end
  end
end
