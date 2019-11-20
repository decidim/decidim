# frozen_string_literal: true

class AddScopesToInitiativesVotes < ActiveRecord::Migration[5.2]
  class InitiativeVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
  end

  def change
    add_column :decidim_initiatives_votes, :decidim_scope_id, :integer

    InitiativeVote.reset_column_information

    InitiativeVote.includes(initiative: :scoped_type).find_each do |vote|
      vote.decidim_scope_id = initiative.scoped_type.decidim_scope_id
      vote.save!
    end
  end
end
