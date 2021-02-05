# frozen_string_literal: true

class AddVotingTypeToVotingVoting < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votings, :voting_type, :string, default: "online"
  end
end
