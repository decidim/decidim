# frozen_string_literal: true

class AddHideCanIVoteToVotings < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_votings_votings, :hide_can_i_vote, :boolean, default: false
  end
end
