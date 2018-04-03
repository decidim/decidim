# frozen_string_literal: true

class AddInitiativeSupportsCountToInitiative < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives, :initiative_supports_count, :integer, null: false, default: 0

    reversible do |change|
      change.up do
        Decidim::Initiative.find_each do |initiative|
          initiative.initiative_supports_count = initiative.votes.supports.count
          initiative.save
        end
      end
    end
  end
end
