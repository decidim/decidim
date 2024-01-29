# frozen_string_literal: true

class AddFollowableCounterCacheToVotings < ActiveRecord::Migration[5.2]
  class Voting < ApplicationRecord
    self.table_name = :decidim_votings_votings
  end

  def change
    add_column :decidim_votings_votings, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Voting.reset_column_information
        Voting.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
