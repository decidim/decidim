# frozen_string_literal: true

class AllowMultipleInitiativeVotesCounterCaches < ActiveRecord::Migration[5.2]
  class InitiativeVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
  end

  def change
    add_column :decidim_initiatives, :votes_count, :jsonb, default: {}

    Initiative.reset_column_information

    Initiative.find_each do |initiative|
      Decidim::InitiativesVote.votes.where(initiative: initiative).group(:scope).count.each do |scope, count|
        initiative.votes_count["votes"] ||= {}
        initiative.votes_count["votes"][scope&.id || "global"] = count
      end

      Decidim::InitiativesVote.supports.where(initiative: initiative).group(:scope).count.each do |scope, count|
        initiative.votes_count["supports"] ||= {}
        initiative.votes_count["supports"][scope&.id || "global"] = count
      end

      initiative.save!
    end

    remove_column :decidim_initiatives, :initiative_supports_count
    remove_column :decidim_initiatives, :initiative_votes_count
  end
end
