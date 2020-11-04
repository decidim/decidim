# frozen_string_literal: true

class AddScopesToInitiativesVotes < ActiveRecord::Migration[5.2]
  class InitiativeVote < ApplicationRecord
    self.table_name = :decidim_initiatives_votes
    belongs_to :initiative, foreign_key: "decidim_initiative_id", class_name: "Initiative"
  end

  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
    belongs_to :scoped_type, class_name: "InitiativesTypeScope"
  end

  class InitiativesTypeScope < ApplicationRecord
    self.table_name = :decidim_initiatives_type_scopes
  end

  def change
    add_column :decidim_initiatives_votes, :decidim_scope_id, :integer

    InitiativeVote.reset_column_information

    InitiativeVote.includes(initiative: :scoped_type).find_each do |vote|
      vote.decidim_scope_id = vote.initiative.scoped_type.decidim_scopes_id
      vote.save!
    end
  end
end
