# frozen_string_literal: true

class CreateElectionsBulletinBoardClosures < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_bulletin_board_closures do |t|
      t.string :bb_notes, null: true

      t.belongs_to :decidim_elections_election,
                   null: false,
                   index: { name: "index_decidim_elections_closures_on_election_id" }

      t.timestamps
    end
  end
end
