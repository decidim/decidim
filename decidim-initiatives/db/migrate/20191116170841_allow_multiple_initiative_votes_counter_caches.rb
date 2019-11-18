# frozen_string_literal: true

class AllowMultipleInitiativeVotesCounterCaches < ActiveRecord::Migration[5.2]
  class InitiativeVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
  end

  def change
    add_column :decidim_initiatives, :online_votes, :jsonb, default: {}

    Initiative.reset_column_information

    Initiative.find_each(&:update_online_votes_counters)

    remove_column :decidim_initiatives, :initiative_supports_count
    remove_column :decidim_initiatives, :initiative_votes_count
  end
end
