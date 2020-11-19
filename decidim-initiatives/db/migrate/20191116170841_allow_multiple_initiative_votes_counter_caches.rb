# frozen_string_literal: true

class AllowMultipleInitiativeVotesCounterCaches < ActiveRecord::Migration[5.2]
  class InitiativeVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
    has_many :votes, foreign_key: "decidim_initiative_id", class_name: "InitiativeVote"
  end

  def change
    add_column :decidim_initiatives, :online_votes, :jsonb, default: {}

    Initiative.reset_column_information

    Initiative.find_each do |initiative|
      online_votes = initiative.votes.group(:decidim_scope_id).count.each_with_object({}) do |(scope_id, count), counters|
        counters[scope_id || "global"] = count
        counters["total"] = count
      end

      # rubocop:disable Rails/SkipsModelValidations
      initiative.update_column("online_votes", online_votes)
      # rubocop:enable Rails/SkipsModelValidations
    end

    remove_column :decidim_initiatives, :initiative_supports_count
    remove_column :decidim_initiatives, :initiative_votes_count
  end
end
