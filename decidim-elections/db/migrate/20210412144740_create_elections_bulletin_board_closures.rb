# frozen_string_literal: true

class CreateElectionsBulletinBoardClosures < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_elections_bulletin_board_closures do |t|
      t.belongs_to :decidim_elections_election,
                   null: false,
                   index: false

      t.timestamps
    end
  end
end
