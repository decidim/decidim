# frozen_string_literal: true

class AddInitiativeSupportsCountToInitiative < ActiveRecord::Migration[5.1]
  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
  end

  def change
    add_column :decidim_initiatives, :initiative_supports_count, :integer, null: false, default: 0

    reversible do |change|
      change.up do
        Initiative.find_each do |initiative|
          initiative.initiative_supports_count = initiative.votes.supports.count
          initiative.save
        end
      end
    end
  end
end
