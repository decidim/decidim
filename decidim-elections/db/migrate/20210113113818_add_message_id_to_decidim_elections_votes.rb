# frozen_string_literal: true

class AddMessageIdToDecidimElectionsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_votes, :message_id, :string, null: false
  end
end
